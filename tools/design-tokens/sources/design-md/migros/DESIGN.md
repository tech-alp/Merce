# Migros Web Design System

Source: <https://www.migros.com.tr/>

Captured on 2026-08-03 from the public home page at desktop, tablet, and mobile
viewports. This is a design-system reference, not a copy of Migros assets,
campaign artwork, or content. Product, cart, checkout, and authenticated states
were not sampled.

## Overview

Migros uses a dense, campaign-first retail interface. Pure white surfaces keep
the large amount of product and promotion content readable, while Migros orange
marks primary brand and action moments. Layout becomes a single vertical stream
on small screens and a centered multi-column canvas on desktop.

## Colors

| Role | Value | Evidence |
|---|---:|---|
| Brand | `#EE7624` | Dominant logo, border, navigation, and CTA accent |
| Primary action | `#EE7624` | Observed CTA container and outline |
| Primary text | `#292A2C` | Main UI text |
| Muted text | `#7F8083` | Metadata and placeholders |
| Canvas / surface | `#FFFFFF` | Page, cards, controls |
| Sunken surface | `#F1F2F5` | Skeleton and low-emphasis fills |
| Border | `#C7C8CB` | Search/input outline |
| Secondary action | `#185DAC` | Recommendation action surface |
| Success accent | `#02B61D` | Positive badge accent |

For the current parity pass, Merce keeps the website's observed `#EE7624`
primary container with `#FFFFFF` content. This pair is 2.90:1; its accessibility
upgrade is intentionally deferred. Muted `#7F8083` is limited to disabled,
placeholder, or non-critical metadata; readable secondary text uses `#5F6063`.
The observed success green seeds an accessible runtime recipe: `#E7F8EA`
container with `#006E18` content and outline.

## Typography

- UI family: Inter.
- Loaded UI weights: 400, 500, 600, 700.
- Dominant sizes: 12px and 14px.
- Control and supporting copy: 16px.
- Section headings: 20px and 24px.
- Lexend Deca and Montserrat appeared only as promotion-specific display assets;
  they are not required by the Merce runtime theme.

## Layout

- Base spacing rhythm: 4px, 8px, 16px, 24px, 32px.
- Form controls use a 48px baseline height; the recipe input reaches 56px.
- Desktop uses a centered, fixed-max-width content region.
- Mobile collapses to one column and keeps campaign groups horizontally
  scrollable.
- Observed responsive boundaries: 480px, 576px, 768px, 992px, 1200px, 1440px,
  1600px, and 1800px.
- Respect `prefers-reduced-motion`.

## Elevation & Depth

The main hierarchy is flat. Use borders and tonal surfaces before shadows. White
cards sit on white or very light gray areas; floating overlays may use a restrained
shadow and scrim.

## Shapes

- Compact action radius: 4px.
- Card radius: 8px.
- Input radius: 10px.
- Large promotional/container radius: 16px.
- Badges and indicators may use a full radius.

## Components

- Primary action: orange container, white label, compact radius.
- Secondary action: blue container with white label.
- Input/search: white surface, gray outline, 48px minimum height, 10px radius.
- Retail card: white surface, 8px radius, border or tonal separation.
- Campaign artwork is content, not a reusable component token.

## Do's and Don'ts

- Do use orange selectively for brand and primary action emphasis.
- Do keep retail layouts dense but preserve clear groups and touch targets.
- Do use semantic token roles instead of raw palette values in QML.
- Don't copy Migros logos, campaign artwork, or marketing copy into Merce.
- Don't introduce promotional display fonts without an explicit license and
  runtime asset decision.
