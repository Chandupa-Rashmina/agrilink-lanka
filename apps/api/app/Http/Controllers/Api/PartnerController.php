<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePartnerRequest;
use App\Http\Requests\UpdatePartnerRequest;
use App\Http\Resources\PartnerResource;
use App\Models\Partner;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class PartnerController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        return PartnerResource::collection(
            Partner::query()
                ->latest()
                ->paginate(20)
        );
    }

    public function store(StorePartnerRequest $request): PartnerResource
    {
        $partner = Partner::query()->create($request->validated());

        return new PartnerResource($partner);
    }

    public function show(Partner $partner): PartnerResource
    {
        return new PartnerResource($partner);
    }

    public function update(
        UpdatePartnerRequest $request,
        Partner $partner
    ): PartnerResource {
        $partner->update($request->validated());

        return new PartnerResource($partner->refresh());
    }

    public function destroy(Partner $partner): Response
    {
        $partner->delete();

        return response()->noContent();
    }
}
