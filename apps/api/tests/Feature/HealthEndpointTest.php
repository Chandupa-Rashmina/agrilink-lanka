<?php

namespace Tests\Feature;

use Tests\TestCase;

class HealthEndpointTest extends TestCase
{
    public function test_health_endpoint_returns_expected_json(): void
    {
        $response = $this->getJson('/api/health');

        $response
            ->assertOk()
            ->assertExactJson([
                'status' => 'ok',
                'service' => 'agrilink-api',
            ]);
    }
}
