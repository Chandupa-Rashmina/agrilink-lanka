<?php

namespace Database\Factories;

use App\Models\Partner;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Partner>
 */
class PartnerFactory extends Factory
{
    protected $model = Partner::class;

    public function definition(): array
    {
        return [
            'type' => fake()->randomElement([
                Partner::TYPE_FARMER,
                Partner::TYPE_SUPPLIER,
            ]),
            'name' => fake()->name(),
            'phone' => fake()->unique()->numerify('07########'),
            'email' => fake()->unique()->safeEmail(),
            'address' => fake()->address(),
            'district' => fake()->randomElement([
                'Colombo',
                'Gampaha',
                'Kandy',
                'Kurunegala',
                'Matara',
            ]),
            'is_active' => true,
        ];
    }

    public function farmer(): static
    {
        return $this->state(fn (): array => [
            'type' => Partner::TYPE_FARMER,
        ]);
    }

    public function supplier(): static
    {
        return $this->state(fn (): array => [
            'type' => Partner::TYPE_SUPPLIER,
        ]);
    }
}
