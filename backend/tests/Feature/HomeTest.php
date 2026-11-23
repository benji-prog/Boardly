<?php

namespace Tests\Feature;

use Tests\TestCase;

class HomeTest extends TestCase
{
    public function test_the_api_root_responds(): void
    {
        $this->getJson('/')
            ->assertOk()
            ->assertJson(['name' => 'Boardly API', 'status' => 'ok']);
    }
}
