export function requiredValue(values, tokenPath) {
  if (!values.has(tokenPath)) {
    throw new Error(`Missing token '${tokenPath}' required by Merce manifest format`);
  }

  return values.get(tokenPath);
}

export function normalizeValue(value) {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    if (Object.prototype.hasOwnProperty.call(value, '$value')
        || Object.prototype.hasOwnProperty.call(value, 'value')) {
      return normalizeValue(value.$value ?? value.value);
    }

    return Object.fromEntries(
      Object.entries(value).map(([key, child]) => [key, normalizeValue(child)]),
    );
  }

  if (typeof value === 'string' && /^-?\d+(\.\d+)?$/.test(value)) {
    return Number(value);
  }

  return value;
}

export function tokenKey(token) {
  if (Array.isArray(token.path)) {
    return token.path.join('.');
  }

  if (typeof token.key === 'string') {
    return token.key.replace(/^\{|\}$/g, '');
  }

  throw new Error(`Token has no path metadata: ${JSON.stringify(token)}`);
}

export function resolveValue(token) {
  return token.$value ?? token.value;
}
