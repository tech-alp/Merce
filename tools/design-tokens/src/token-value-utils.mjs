import { resolveReferences } from 'style-dictionary/utils';

export function requiredValue(values, tokenPath) {
  if (!values.has(tokenPath)) {
    throw new Error(`Missing token '${tokenPath}' required by Merce manifest format`);
  }

  return values.get(tokenPath);
}

export function normalizeValue(value) {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return normalizeValue(value.$value ?? value.value);
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

export function resolveValue(token, tokens) {
  const value = token.$value ?? token.value;

  if (typeof value === 'string' && value.includes('{')) {
    return resolveReferences(value, tokens, { usesDtcg: true });
  }

  return value;
}
