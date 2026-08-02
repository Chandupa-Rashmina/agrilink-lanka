<?php

namespace App\Http\Requests;

use App\Models\Partner;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdatePartnerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $partner = $this->route('partner');

        return [
            'type' => [
                'sometimes',
                'required',
                Rule::in([
                    Partner::TYPE_FARMER,
                    Partner::TYPE_SUPPLIER,
                ]),
            ],
            'name' => ['sometimes', 'required', 'string', 'max:150'],
            'phone' => [
                'nullable',
                'string',
                'max:30',
                Rule::unique('partners', 'phone')->ignore($partner),
            ],
            'email' => [
                'nullable',
                'email',
                'max:255',
                Rule::unique('partners', 'email')->ignore($partner),
            ],
            'address' => ['nullable', 'string'],
            'district' => ['nullable', 'string', 'max:100'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
