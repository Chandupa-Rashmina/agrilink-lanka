<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MarketplaceMapContactTest extends TestCase
{
    use RefreshDatabase;

    public function test_listing_can_store_and_return_coordinates(): void
    {
        $seller = User::factory()->create();
        $category = Category::create([
            'name' => 'Vegetables',
            'slug' => 'vegetables',
            'is_active' => true,
        ]);

        $response = $this->actingAs($seller, 'sanctum')
            ->postJson('/api/listings', [
                'category_id' => $category->id,
                'title' => 'Mapped tomatoes',
                'quantity' => 50,
                'unit' => 'kg',
                'price' => 300,
                'district' => 'Kandy',
                'latitude' => 7.290572,
                'longitude' => 80.633728,
            ])
            ->assertCreated()
            ->assertJsonPath('data.latitude', '7.2905720')
            ->assertJsonPath('data.longitude', '80.6337280');

        $this->assertDatabaseHas('listings', [
            'id' => $response->json('data.id'),
            'latitude' => 7.290572,
            'longitude' => 80.633728,
        ]);
    }

    public function test_authenticated_buyer_can_read_seller_contact(): void
    {
        $seller = User::factory()->create([
            'phone' => '0771234567',
            'district' => 'Kandy',
        ]);
        $buyer = User::factory()->create();
        $listing = $this->listingFor($seller);

        $this->actingAs($buyer, 'sanctum')
            ->getJson("/api/listings/{$listing->id}/contact")
            ->assertOk()
            ->assertJsonPath('data.phone', '0771234567')
            ->assertJsonPath('data.district', 'Kandy');
    }

    public function test_owner_cannot_request_own_contact_endpoint(): void
    {
        $seller = User::factory()->create();
        $listing = $this->listingFor($seller);

        $this->actingAs($seller, 'sanctum')
            ->getJson("/api/listings/{$listing->id}/contact")
            ->assertUnprocessable();
    }

    private function listingFor(User $seller): Listing
    {
        $category = Category::firstOrCreate(
            ['slug' => 'vegetables'],
            ['name' => 'Vegetables', 'is_active' => true],
        );

        return Listing::create([
            'user_id' => $seller->id,
            'category_id' => $category->id,
            'title' => 'Fresh produce',
            'quantity' => 10,
            'unit' => 'kg',
            'price' => 250,
            'district' => 'Kandy',
            'status' => 'active',
        ]);
    }
}
