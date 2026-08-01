import {
  normalizeValue,
  requiredValue,
  resolveValue,
  tokenKey,
} from './token-value-utils.mjs';

export const COLOR_FIELD_MAP = {
  surface: [
    'canvas',
    'container',
    'containerRaised',
    'containerSunken',
    'containerTinted',
    'floating',
    'scrim',
    'inverse',
    'shadow',
  ],
  content: [
    'primary',
    'secondary',
    'tertiary',
    'inverse',
    'disabled',
    'link',
  ],
  action: [
    'primary.container',
    'primary.content',
    'primary.outline',
    'secondary.container',
    'secondary.content',
    'secondary.outline',
    'destructive.container',
    'destructive.content',
    'destructive.outline',
  ],
  status: [
    'success.container',
    'success.content',
    'success.outline',
    'warning.container',
    'warning.content',
    'warning.outline',
    'error.container',
    'error.content',
    'error.outline',
    'info.container',
    'info.content',
    'info.outline',
    'neutral.container',
    'neutral.content',
    'neutral.outline',
  ],
  outline: [
    'subtle',
    'strong',
    'focus',
  ],
};

export const STATE_FIELD_MAP = {
  layer: [
    'hover',
    'focus',
    'pressed',
    'selected',
  ],
  disabled: [
    'containerOpacity',
    'contentOpacity',
  ],
};

export const PROFILE_FIELD_MAP = {
  spacing: [
    'base',
    'none',
    'xxs',
    'xs',
    'sm',
    'md',
    'lg',
    'xl',
    'xl2',
    'xl3',
    'xl4',
    'xl5',
    'xl6',
    'componentGap',
    'sectionGap',
    'pagePadding',
    'touchTarget',
    'touchTargetCompact',
    'gridGap',
    'stackGap',
    'inlineGap',
  ],
  radius: [
    'none',
    'small',
    'medium',
    'large',
    'xlarge',
    'xxlarge',
    'full',
    'button',
    'input',
    'card',
    'badge',
    'dialog',
    'tooltip',
  ],
  typography: [
    'displayFont',
    'bodyFont',
    'monoFont',
    'displayFontFallback',
    'bodyFontFallback',
    'sizeXSmall',
    'sizeSmall',
    'sizeMedium',
    'sizeLarge',
    'sizeXLarge',
    'size2XLarge',
    'size3XLarge',
    'size4XLarge',
    'size5XLarge',
    'size6XLarge',
    'size7XLarge',
    'weightRegular',
    'weightMedium',
    'weightSemibold',
    'weightBold',
    'leadingTight',
    'leadingSnug',
    'leadingNormal',
    'leadingRelaxed',
    'trackingTight',
    'trackingNormal',
    'trackingWide',
    'trackingWider',
    'trackingWidest',
  ],
  size: [
    'control.small',
    'control.medium',
    'control.large',
    'control.minimum',
    'icon.small',
    'icon.medium',
    'icon.large',
    'outline.hairline',
    'outline.strong',
    'outline.focus',
  ],
};

function tokenValues(dictionary) {
  return new Map(
    dictionary.allTokens.map((token) => [
      tokenKey(token),
      normalizeValue(resolveValue(token, dictionary.tokens)),
    ]),
  );
}

function assignNestedField(target, fieldPath, value) {
  const segments = fieldPath.split('.');
  let cursor = target;

  for (const segment of segments.slice(0, -1)) {
    cursor[segment] ??= {};
    cursor = cursor[segment];
  }

  cursor[segments.at(-1)] = value;
}

function mappedObject(prefix, groups, values) {
  return Object.fromEntries(
    Object.entries(groups).map(([group, fields]) => {
      const result = {};
      for (const field of fields) {
        assignNestedField(result, field, requiredValue(values, `${prefix}.${group}.${field}`));
      }
      return [group, result];
    }),
  );
}

export function formatResolvedTheme(dictionary, options) {
  const values = tokenValues(dictionary);
  const colors = mappedObject('color', COLOR_FIELD_MAP, values);
  const state = mappedObject('state', STATE_FIELD_MAP, values);
  const scrim = colors.surface.scrim;
  if (!/^#[0-9a-fA-F]{8}$/.test(scrim)) {
    throw new Error('color.surface.scrim must be an #RRGGBBAA color');
  }
  colors.surface.scrim = `#${scrim.slice(7)}${scrim.slice(1, 7)}`;

  return {
    kind: 'resolved-theme',
    resolvedThemeSchemaVersion: 1,
    brandId: options.brandId,
    mode: options.mode,
    identity: {
      mark: requiredValue(values, 'identity.mark'),
    },
    colors,
    state,
  };
}

export function formatProfile(dictionary, options) {
  const values = tokenValues(dictionary);
  const profile = {
    profileSchemaVersion: 1,
    profileId: options.profileId,
  };

  for (const [section, fields] of Object.entries(PROFILE_FIELD_MAP)) {
    const result = {};
    for (const field of fields) {
      assignNestedField(result, field, requiredValue(values, `${section}.${field}`));
    }
    profile[section] = result;
  }

  return profile;
}
