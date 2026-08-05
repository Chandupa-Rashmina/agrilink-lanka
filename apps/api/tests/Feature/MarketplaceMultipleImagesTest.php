<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class MarketplaceMultipleImagesTest extends TestCase
{
    use RefreshDatabase;

    public function test_listing_can_upload_multiple_ordered_images(): void
    {
        Storage::fake('public');

        $seller = User::factory()->create();
        $category = $this->category();

        $response = $this->actingAs($seller, 'sanctum')
            ->post('/api/listings', [
                'category_id' => $category->id,
                'title' => 'Image listing',
                'quantity' => 20,
                'unit' => 'kg',
                'price' => 250,
                'district' => 'Kandy',
                'images' => [
                    $this->fakePng('cover.png'),
                    $this->fakePng('second.png'),
                ],
            ], ['Accept' => 'application/json'])
            ->assertCreated()
            ->assertJsonCount(2, 'data.images')
            ->assertJsonPath('data.images.0.is_cover', true);

        $this->assertDatabaseCount('listing_images', 2);
        $this->assertNotNull($response->json('data.image_url'));
    }

    public function test_owner_can_change_cover_and_delete_image(): void
    {
        Storage::fake('public');

        $seller = User::factory()->create();
        $listing = $this->listing($seller);

        $first = $listing->images()->create([
            'path' => $this->fakePng('one.png')
                ->store('listings', 'public'),
            'sort_order' => 0,
        ]);
        $second = $listing->images()->create([
            'path' => $this->fakePng('two.png')
                ->store('listings', 'public'),
            'sort_order' => 1,
        ]);

        $this->actingAs($seller, 'sanctum')
            ->patchJson(
                "/api/listings/{$listing->id}/images/{$second->id}/cover"
            )
            ->assertOk()
            ->assertJsonPath('data.images.0.id', $second->id)
            ->assertJsonPath('data.images.0.is_cover', true);

        $this->actingAs($seller, 'sanctum')
            ->deleteJson(
                "/api/listings/{$listing->id}/images/{$first->id}"
            )
            ->assertNoContent();

        $this->assertDatabaseMissing('listing_images', [
            'id' => $first->id,
        ]);
    }

    public function test_listing_rejects_more_than_five_images(): void
    {
        Storage::fake('public');

        $seller = User::factory()->create();

        $images = [];
        for ($index = 0; $index < 6; $index++) {
            $images[] = $this->fakePng("image-{$index}.png");
        }

        $this->actingAs($seller, 'sanctum')
            ->post('/api/listings', [
                'category_id' => $this->category()->id,
                'title' => 'Too many images',
                'quantity' => 20,
                'unit' => 'kg',
                'price' => 250,
                'district' => 'Kandy',
                'images' => $images,
            ], ['Accept' => 'application/json'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('images');
    }

    private function fakePng(string $name): UploadedFile
    {
        $png = base64_decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
            .'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='
        );

        return UploadedFile::fake()->createWithContent($name, $png);
    }

    private function listing(User $seller): Listing
    {
        return Listing::create([
            'user_id' => $seller->id,
            'category_id' => $this->category()->id,
            'title' => 'Produce',
            'quantity' => 10,
            'unit' => 'kg',
            'price' => 100,
            'district' => 'Kandy',
            'status' => 'active',
        ]);
    }

    private function category(): Category
    {
        return Category::firstOrCreate(
            ['slug' => 'vegetables'],
            ['name' => 'Vegetables', 'is_active' => true],
        );
    }
}
