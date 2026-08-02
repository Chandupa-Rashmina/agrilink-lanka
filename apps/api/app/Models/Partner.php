<?php

namespace App\Models;

use Database\Factories\PartnerFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Partner extends Model
{
    /** @use HasFactory<PartnerFactory> */
    use HasFactory;

    public const TYPE_FARMER = 'farmer';

    public const TYPE_SUPPLIER = 'supplier';

    protected $fillable = [
        'type',
        'name',
        'phone',
        'email',
        'address',
        'district',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }
}
