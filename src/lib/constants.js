// src/lib/constants.js

export function rankNumberToLabel(value) {
  const ranks = [
    "Herald", "Guardian", "Crusader", "Archon", "Legend",
    "Ancient", "Divine", "Immortal"
  ];
  if (typeof value !== 'number' || value < 0) return "Unknown";

  const tier = Math.floor(value / 5);
  const star = (value % 5) + 1;

  return tier < ranks.length - 1
    ? `${ranks[tier]} ${star} Star`
    : "Immortal";
}
