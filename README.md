# Bot Trade - Mobile Auth UI

Flutter authentication screens with taste-skill design system.

## Design System

- **Dark Theme**: `#070B14` background, `#0D1321` elevated surface
- **Accent**: `#38BDF8` cyan/sky blue with glow effects
- **Typography**: Inter (body), Space Grotesk (headings)
- **Style**: Glassmorphism cards, sharp hierarchy, generous whitespace

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── features/
│   └── auth/
│       ├── login_screen.dart          # Login with email/password + magic link
│       └── register_screen.dart       # Register with form validation
├── theme/
│   ├── app_colors.dart               # Color palette & gradients
│   ├── app_theme.dart                # Material theme configuration
│   └── theme.dart                    # Barrel export
└── widgets/
    ├── animated_button.dart          # Scale animation + loading state
    ├── floating_label_input.dart     # Animated label + focus glow
    ├── glassmorphism_card.dart       # Frosted glass container
    ├── shimmer_loading.dart          # Shimmer placeholder effect
    └── widgets.dart                  # Barrel export
```

## Getting Started

1. Install fonts to `assets/fonts/` (Inter & Space Grotesk)
2. Run `flutter pub get`
3. Run `flutter run`

## Animations

- Fade + Slide entrance with staggered timing
- Scale on press (buttons compress to 95%)
- Focus glow on input fields
- Elastic scale for logo
- Slide page transition between screens

