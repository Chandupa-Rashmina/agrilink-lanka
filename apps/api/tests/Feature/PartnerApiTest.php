<?php

namespace Tests\Feature;

use App\Models\Partner;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PartnerApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_partner_can_be_created(): void
    {
        $response = $this->postJson('/api/partners', [
            'type' => Partner::TYPE_FARMER,
            'name' => 'Nimal Farmer',
            'phone' => '0711111111',
            'email' => 'nimal@example.test',
            'district' => 'Kandy',
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.type', Partner::TYPE_FARMER)
            ->assertJsonPath('data.name', 'Nimal Farmer');

        $this->assertDatabaseHas('partners', [
            'name' => 'Nimal Farmer',
            'phone' => '0711111111',
        ]);
    }

    public function test_partners_can_be_listed(): void
    {
        Partner::factory()->count(3)->create();

        $response = $this->getJson('/api/partners');

        $response
            ->assertOk()
            ->assertJsonCount(3, 'data');
    }

    public function test_single_partner_can_be_viewed(): void
    {
        $partner = Partner::factory()->farmer()->create();

        $response = $this->getJson("/api/partners/{$partner->id}");

        $response
            ->assertOk()
            ->assertJsonPath('data.id', $partner->id)
            ->assertJsonPath('data.type', Partner::TYPE_FARMER);
    }

    public function test_partner_can_be_updated(): void
    {
        $partner = Partner::factory()->supplier()->create([
            'name' => 'Old Supplier',
        ]);

        $response = $this->putJson("/api/partners/{$partner->id}", [
            'name' => 'Updated Supplier',
            'is_active' => false,
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('data.name', 'Updated Supplier')
            ->assertJsonPath('data.is_active', false);

        $this->assertDatabaseHas('partners', [
            'id' => $partner->id,
            'name' => 'Updated Supplier',
            'is_active' => false,
        ]);
    }

    public function test_invalid_partner_data_is_rejected(): void
    {
        $response = $this->postJson('/api/partners', [
            'type' => 'invalid',
            'name' => '',
            'email' => 'not-an-email',
        ]);

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'type',
                'name',
                'email',
            ]);
    }

    public function test_partner_can_be_deleted(): void
    {
        $partner = Partner::factory()->create();

        $response = $this->deleteJson("/api/partners/{$partner->id}");

        $response->assertNoContent();

        $this->assertDatabaseMissing('partners', [
            'id' => $partner->id,
        ]);
    }
}
