<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MarketplaceUserFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_read_and_update_profile(): void
    {
        $register = $this->postJson('/api/register', [
            'name' => 'Buyer User',
            'email' => 'buyer@example.com',
            'phone' => '0771234567',
            'district' => 'Kandy',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'device_name' => 'test',
        ])
            ->assertCreated()
            ->assertJsonPath('data.user.phone', '0771234567');

        $token = $register->json('data.token');

        $this->withToken($token)
            ->getJson('/api/me')
            ->assertOk()
            ->assertJsonPath('data.district', 'Kandy');

        $this->withToken($token)
            ->putJson('/api/profile', [
                'name' => 'Updated Buyer',
                'email' => 'buyer@example.com',
                'phone' => '0711111111',
                'district' => 'Colombo',
            ])
            ->assertOk()
            ->assertJsonPath('data.name', 'Updated Buyer')
            ->assertJsonPath('data.district', 'Colombo');
    }
}
