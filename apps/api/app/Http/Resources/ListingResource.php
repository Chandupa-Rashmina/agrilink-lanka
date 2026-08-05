<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ListingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $this->loadMissing('images');

        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'quantity' => $this->quantity,
            'unit' => $this->unit,
            'price' => $this->price,
            'is_negotiable' => $this->is_negotiable,
            'district' => $this->district,
            'location' => $this->location,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'available_date' => $this->available_date?->toDateString(),
            'image_url' => $this->image_url,
            'images' => $this->images->map(
                fn ($image) => [
                    'id' => $image->id,
                    'url' => $image->url,
                    'sort_order' => $image->sort_order,
                    'is_cover' => $image->sort_order === 0,
                ]
            )->values(),
            'status' => $this->status,
            'category' => [
                'id' => $this->category?->id,
                'name' => $this->category?->name,
                'slug' => $this->category?->slug,
            ],
            'seller' => [
                'id' => $this->seller?->id,
                'name' => $this->seller?->name,
                'email' => $this->seller?->email,
                'district' => $this->seller?->district,
            ],
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
