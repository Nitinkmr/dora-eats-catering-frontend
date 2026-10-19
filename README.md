# Dora Catering — Flutter Web

Responsive CaterNinja-inspired catering catalogue frontend. Includes API-driven food cards, category filters, search, guest count, add-on quantities, and a live order summary.

## Requirements
- Flutter stable (Dart 3.3+)
- A catalogue endpoint returning either a JSON list or an object shaped like `{ "items": [...] }`

## Run

```bash
flutter pub get
flutter run -d chrome --dart-define=CATALOGUE_API_URL=https://YOUR_API_HOST/YOUR_CATALOGUE_PATH
```

Build for deployment:

```bash
flutter build web --release --dart-define=CATALOGUE_API_URL=https://YOUR_API_HOST/YOUR_CATALOGUE_PATH
```

`CATALOGUE_API_URL` must be the full URL of the catalogue endpoint, not just the API host. If the endpoint needs query parameters, include them in the URL. This starter currently sends a GET request with `Accept: application/json` and no auth headers.

## Expected response

```json
{
  "items": [
    {
      "categoryId": "starter-id",
      "displayName": "paneer tikka masala",
      "pricePerPerson": 100,
      "quantityPerPerson": 200,
      "type": "food"
    },
    {
      "categoryId": "service-id",
      "displayName": "extra server",
      "price": 700,
      "type": "add-on"
    }
  ]
}
```

Optional fields supported: `id` or `itemId`, `categoryName` or `categoryDisplayName`, `description`, `imageUrl`, `image`, `photoUrl`.

## Pricing assumptions
- Food: `pricePerPerson × guest count` for each selected dish.
- Add-ons: `price × selected add-on quantity`.
- `quantityPerPerson` is displayed as a serving quantity only; it does not affect price calculations.
- Taxes, delivery, discounts, and booking submission are not implemented because no contract for those APIs was provided.

Please confirm that your backend defines prices this way. The frontend currently treats each food item as optional (added/removed) and each add-on as a quantity-based extra.

## Web API / CORS
For Flutter Web, the API server must allow browser requests from the deployed frontend origin via CORS. If your endpoint requires authentication, update `CatalogueApi.fetchCatalogue()` to attach the appropriate headers. Do not place long-lived secret API keys in frontend code.

## Project structure

- `lib/main.dart` — app theme and provider setup
- `lib/models/catalogue_item.dart` — tolerant catalogue item parser
- `lib/services/catalogue_api.dart` — HTTP API client
- `lib/state/catering_state.dart` — menu, guest count, add-ons, and price calculations
- `lib/screens/catalogue_page.dart` — responsive catalogue layout and category filters
- `lib/widgets/food_card.dart` — food item card
- `lib/widgets/order_summary.dart` — live cart and estimated total

## Before production
1. Add real category labels/order from a category endpoint or include them in the catalogue payload.
2. Confirm pricing rules and serving-unit conventions.
3. Connect “Continue to event details” to your booking/order API.
4. Add event date, address/pincode, contact details, validation, and payment/confirmation flow.
5. Add tests and configure CORS, analytics, and error reporting.
