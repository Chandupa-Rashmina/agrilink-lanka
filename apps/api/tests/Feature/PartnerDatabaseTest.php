<?php

namespace Tests\Feature;

use App\Models\Partner;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PartnerDatabaseTest extends TestCase
{
    use RefreshDatabase;

    public function test_farmer_partner_can_be_stored_in_the_database(): void
    {
        $partner = Partner::factory()->farmer()->create([
            'name' => 'Test Farmer',
            'phone' => '0712345678',
            'email' => 'farmer@example.test',
        ]);

        $this->assertDatabaseHas('partners', [
            'id' => $partner->id,
            'type' => Partner::TYPE_FARMER,
            'name' => 'Test Farmer',
            'phone' => '0712345678',
            'email' => 'farmer@example.test',
            'is_active' => true,
        ]);
    }

    public function test_supplier_partner_can_be_stored_in_the_database(): void
    {
        $partner = Partner::factory()->supplier()->create([
            'name' => 'Test Supplier',
        ]);

        $this->assertDatabaseHas('partners', [
            'id' => $partner->id,
            'type' => Partner::TYPE_SUPPLIER,
            'name' => 'Test Supplier',
            'is_active' => true,
        ]);
    }
}
