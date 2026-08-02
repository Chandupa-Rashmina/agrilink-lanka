<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthenticationTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_login_and_receive_token(): void
    {
        $user = User::factory()->create([
            'email' => 'user@example.test',
            'password' => Hash::make('secret-password'),
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'secret-password',
            'device_name' => 'test-android',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('data.user.email', $user->email)
            ->assertJsonStructure([
                'data' => [
                    'user' => ['id', 'name', 'email'],
                    'token',
                ],
            ]);

        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_invalid_credentials_are_rejected(): void
    {
        User::factory()->create([
            'email' => 'user@example.test',
            'password' => Hash::make('correct-password'),
        ]);

        $this->postJson('/api/login', [
            'email' => 'user@example.test',
            'password' => 'wrong-password',
        ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('email');
    }

    public function test_partner_routes_require_authentication(): void
    {
        $this->getJson('/api/partners')
            ->assertUnauthorized();
    }

    public function test_user_can_logout_and_revoke_token(): void
    {
        $user = User::factory()->create([
            'email' => 'user@example.test',
            'password' => Hash::make('secret-password'),
        ]);

        $login = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'secret-password',
        ])->assertOk();

        $token = $login->json('data.token');

        $this->withToken($token)
            ->postJson('/api/logout')
            ->assertNoContent();

        Auth::forgetGuards();

        $this->withToken($token)
            ->getJson('/api/partners')
            ->assertUnauthorized();

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }
}
