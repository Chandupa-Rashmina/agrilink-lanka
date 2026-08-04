<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MarketplaceApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_marketplace_core_flow_works(): void
    {
        $seller = User::factory()->create();
        $buyer = User::factory()->create();

        $category = Category::create([
            'name' => 'Vegetables',
            'slug' => 'vegetables',
            'is_active' => true,
        ]);

        $this->getJson('/api/categories')
            ->assertOk()
            ->assertJsonPath('data.0.slug', 'vegetables');

        $createResponse = $this
            ->actingAs($seller, 'sanctum')
            ->postJson('/api/listings', [
                'category_id' => $category->id,
                'title' => 'Fresh tomatoes',
                'description' => 'Harvested this morning.',
                'quantity' => 100,
                'unit' => 'kg',
                'price' => 350,
                'is_negotiable' => true,
                'district' => 'Kandy',
                'location' => 'Peradeniya',
            ])
            ->assertCreated()
            ->assertJsonPath('data.title', 'Fresh tomatoes');

        $listingId = $createResponse->json('data.id');

        $this->getJson('/api/listings?search=tomato&district=Kandy')
            ->assertOk()
            ->assertJsonPath('data.0.id', $listingId);

        $this
            ->actingAs($buyer, 'sanctum')
            ->postJson("/api/favorites/{$listingId}")
            ->assertOk();

        $this
            ->actingAs($buyer, 'sanctum')
            ->getJson('/api/favorites')
            ->assertOk()
            ->assertJsonPath('data.0.id', $listingId);

        $inquiryResponse = $this
            ->actingAs($buyer, 'sanctum')
            ->postJson("/api/listings/{$listingId}/inquiries", [
                'message' => 'Can I buy 20 kg tomorrow?',
            ])
            ->assertCreated()
            ->assertJsonPath('data.status', 'pending');

        $inquiryId = $inquiryResponse->json('data.id');

        $this
            ->actingAs($seller, 'sanctum')
            ->patchJson("/api/inquiries/{$inquiryId}", [
                'status' => 'accepted',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'accepted');

        $this
            ->actingAs($seller, 'sanctum')
            ->postJson("/api/listings/{$listingId}/sold")
            ->assertOk()
            ->assertJsonPath('data.status', 'sold');

        $this->getJson("/api/listings/{$listingId}")
            ->assertNotFound();
    }

    public function test_users_cannot_modify_other_users_listings(): void
    {
        $owner = User::factory()->create();
        $otherUser = User::factory()->create();

        $category = Category::create([
            'name' => 'Fruits',
            'slug' => 'fruits',
            'is_active' => true,
        ]);

        $listing = Listing::create([
            'user_id' => $owner->id,
            'category_id' => $category->id,
            'title' => 'Bananas',
            'quantity' => 25,
            'unit' => 'kg',
            'price' => 220,
            'district' => 'Matale',
            'status' => 'active',
        ]);

        $this
            ->actingAs($otherUser, 'sanctum')
            ->deleteJson("/api/listings/{$listing->id}")
            ->assertForbidden();
    }
}
