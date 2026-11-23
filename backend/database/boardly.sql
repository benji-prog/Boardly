-- ============================================================================
-- Boardly – adatbázisséma
-- Adatbázis-kezelő: MySQL 8.0 vagy újabb
--
-- Az összetett idegen kulcsok biztosítják, hogy az egymáshoz kapcsolt sorok
-- (feladat és oszlop, feladat és címke, felelős és projekttag) ugyanahhoz a
-- projekthez tartozzanak. A szöveges ellenőrző megszorítások bináris
-- összehasonlítást használnak, így a kis- és nagybetűk különbözőnek számítanak.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS boardly
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE boardly;

-- Felhasználói fiókok
CREATE TABLE users (
    id              INTEGER AUTO_INCREMENT PRIMARY KEY,
    email           VARCHAR(254) NOT NULL,
    username        VARCHAR(30)  NOT NULL,
    full_name       VARCHAR(100) NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    theme           VARCHAR(10)  NOT NULL DEFAULT 'system',
    system_role     VARCHAR(10)  NOT NULL DEFAULT 'user',
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT ck_users_email_lower CHECK (email COLLATE utf8mb4_bin = LOWER(email) COLLATE utf8mb4_bin),
    CONSTRAINT ck_users_username CHECK (username COLLATE utf8mb4_bin = LOWER(username) COLLATE utf8mb4_bin AND CHAR_LENGTH(username) >= 3),
    CONSTRAINT ck_users_theme CHECK (theme COLLATE utf8mb4_bin IN ('light', 'dark', 'system')),
    CONSTRAINT ck_users_system_role CHECK (system_role COLLATE utf8mb4_bin IN ('user', 'admin'))
);

-- Projektek
CREATE TABLE projects (
    id              INTEGER AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    description     TEXT         NULL,
    archived_at     TIMESTAMP    NULL,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Projekttagságok és projektszintű szerepkörök
CREATE TABLE project_members (
    project_id      INTEGER      NOT NULL,
    user_id         INTEGER      NOT NULL,
    role            VARCHAR(10)  NOT NULL DEFAULT 'member',
    joined_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_project_members PRIMARY KEY (project_id, user_id),
    CONSTRAINT fk_project_members_project FOREIGN KEY (project_id)
        REFERENCES projects (id) ON DELETE CASCADE,
    CONSTRAINT fk_project_members_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT ck_project_members_role CHECK (role COLLATE utf8mb4_bin IN ('owner', 'manager', 'member'))
);
CREATE INDEX ix_project_members_user ON project_members (user_id);

-- A Kanban-tábla státuszoszlopai
CREATE TABLE board_columns (
    id              INTEGER AUTO_INCREMENT PRIMARY KEY,
    project_id      INTEGER      NOT NULL,
    name            VARCHAR(50)  NOT NULL,
    sort_order      INTEGER      NOT NULL,
    is_done         BOOLEAN      NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_board_columns_project_id UNIQUE (project_id, id),
    CONSTRAINT uq_board_columns_project_name UNIQUE (project_id, name),
    CONSTRAINT fk_board_columns_project FOREIGN KEY (project_id)
        REFERENCES projects (id) ON DELETE CASCADE,
    CONSTRAINT ck_board_columns_sort_order CHECK (sort_order >= 0)
);
CREATE INDEX ix_board_columns_order ON board_columns (project_id, sort_order);

-- Projektszintű címkék
CREATE TABLE labels (
    id              INTEGER AUTO_INCREMENT PRIMARY KEY,
    project_id      INTEGER      NOT NULL,
    name            VARCHAR(30)  NOT NULL,
    color           CHAR(7)      NOT NULL,
    CONSTRAINT uq_labels_project_id UNIQUE (project_id, id),
    CONSTRAINT uq_labels_project_name UNIQUE (project_id, name),
    CONSTRAINT fk_labels_project FOREIGN KEY (project_id)
        REFERENCES projects (id) ON DELETE CASCADE,
    CONSTRAINT ck_labels_color CHECK (color LIKE '#______')
);

-- Feladatkártyák
CREATE TABLE tasks (
    id              INTEGER AUTO_INCREMENT PRIMARY KEY,
    project_id      INTEGER      NOT NULL,
    column_id       INTEGER      NOT NULL,
    title           VARCHAR(200) NOT NULL,
    description     TEXT         NULL,
    priority        VARCHAR(10)  NOT NULL DEFAULT 'medium',
    sort_order      INTEGER      NOT NULL,
    due_date        DATE         NULL,
    completed_at    TIMESTAMP    NULL,
    created_by      INTEGER      NOT NULL,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_tasks_project_id UNIQUE (project_id, id),
    CONSTRAINT fk_tasks_project FOREIGN KEY (project_id)
        REFERENCES projects (id) ON DELETE CASCADE,
    CONSTRAINT fk_tasks_column FOREIGN KEY (project_id, column_id)
        REFERENCES board_columns (project_id, id) ON DELETE NO ACTION,
    CONSTRAINT fk_tasks_created_by FOREIGN KEY (created_by)
        REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT ck_tasks_priority CHECK (priority COLLATE utf8mb4_bin IN ('low', 'medium', 'high', 'urgent')),
    CONSTRAINT ck_tasks_sort_order CHECK (sort_order >= 0)
);
CREATE INDEX ix_tasks_board ON tasks (project_id, column_id, sort_order);
CREATE INDEX ix_tasks_due_date ON tasks (due_date);
CREATE INDEX ix_tasks_created_by ON tasks (created_by);

-- Feladatok és címkék kapcsolata
CREATE TABLE task_labels (
    project_id      INTEGER      NOT NULL,
    task_id         INTEGER      NOT NULL,
    label_id        INTEGER      NOT NULL,
    CONSTRAINT pk_task_labels PRIMARY KEY (project_id, task_id, label_id),
    CONSTRAINT fk_task_labels_task FOREIGN KEY (project_id, task_id)
        REFERENCES tasks (project_id, id) ON DELETE CASCADE,
    CONSTRAINT fk_task_labels_label FOREIGN KEY (project_id, label_id)
        REFERENCES labels (project_id, id) ON DELETE CASCADE
);
CREATE INDEX ix_task_labels_label ON task_labels (project_id, label_id);

-- Feladatok felelősei
CREATE TABLE task_assignees (
    project_id      INTEGER      NOT NULL,
    task_id         INTEGER      NOT NULL,
    user_id         INTEGER      NOT NULL,
    assigned_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_task_assignees PRIMARY KEY (project_id, task_id, user_id),
    CONSTRAINT fk_task_assignees_task FOREIGN KEY (project_id, task_id)
        REFERENCES tasks (project_id, id) ON DELETE CASCADE,
    CONSTRAINT fk_task_assignees_member FOREIGN KEY (project_id, user_id)
        REFERENCES project_members (project_id, user_id) ON DELETE CASCADE
);
CREATE INDEX ix_task_assignees_member ON task_assignees (project_id, user_id);
CREATE INDEX ix_task_assignees_user ON task_assignees (user_id);

-- Hozzászólások
CREATE TABLE comments (
    id              INTEGER AUTO_INCREMENT PRIMARY KEY,
    task_id         INTEGER      NOT NULL,
    author_id       INTEGER      NOT NULL,
    body            TEXT         NOT NULL,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comments_task FOREIGN KEY (task_id)
        REFERENCES tasks (id) ON DELETE CASCADE,
    CONSTRAINT fk_comments_author FOREIGN KEY (author_id)
        REFERENCES users (id) ON DELETE RESTRICT
);
CREATE INDEX ix_comments_task ON comments (task_id, created_at);
CREATE INDEX ix_comments_author ON comments (author_id);

-- Tevékenységnapló
CREATE TABLE activity_logs (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    project_id      INTEGER      NOT NULL,
    task_id         INTEGER      NULL,
    actor_id        INTEGER      NOT NULL,
    event_type      VARCHAR(40)  NOT NULL,
    details         TEXT         NULL,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_activity_logs_project FOREIGN KEY (project_id)
        REFERENCES projects (id) ON DELETE CASCADE,
    CONSTRAINT fk_activity_logs_task FOREIGN KEY (task_id)
        REFERENCES tasks (id) ON DELETE SET NULL,
    CONSTRAINT fk_activity_logs_actor FOREIGN KEY (actor_id)
        REFERENCES users (id) ON DELETE RESTRICT
);
CREATE INDEX ix_activity_logs_project ON activity_logs (project_id, created_at);
CREATE INDEX ix_activity_logs_task ON activity_logs (task_id);
CREATE INDEX ix_activity_logs_actor ON activity_logs (actor_id);

-- Értesítések
CREATE TABLE notifications (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    recipient_id    INTEGER      NOT NULL,
    actor_id        INTEGER      NULL,
    project_id      INTEGER      NOT NULL,
    task_id         INTEGER      NULL,
    event_type      VARCHAR(20)  NOT NULL,
    read_at         TIMESTAMP    NULL,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_recipient FOREIGN KEY (recipient_id)
        REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_notifications_actor FOREIGN KEY (actor_id)
        REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_notifications_project FOREIGN KEY (project_id)
        REFERENCES projects (id) ON DELETE CASCADE,
    CONSTRAINT fk_notifications_task FOREIGN KEY (project_id, task_id)
        REFERENCES tasks (project_id, id) ON DELETE CASCADE,
    CONSTRAINT ck_notifications_event_type CHECK
        (event_type COLLATE utf8mb4_bin IN ('task_assigned', 'task_commented', 'task_due_soon', 'member_added'))
);
CREATE INDEX ix_notifications_inbox ON notifications (recipient_id, read_at, created_at);
CREATE INDEX ix_notifications_actor ON notifications (actor_id);
CREATE INDEX ix_notifications_task ON notifications (project_id, task_id);
