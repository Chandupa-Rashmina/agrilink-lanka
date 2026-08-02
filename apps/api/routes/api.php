<?php

use App\Http\Controllers\Api\PartnerController;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'service' => 'agrilink-api',
    ]);
});

Route::apiResource('partners', PartnerController::class);
