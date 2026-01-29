# Market Explorer – New Plan

## Goal
Make Market Explorer feel like a realistic (but game-friendly) market sim that uses in-game coins as invested capital, runs on a 24-hour year cycle, and allows a single mid-year rebalance window at 12 hours.

## Currency
- Use in-game `coins` as investable balance.
- Investment gains/losses update the player’s coin balance at year-end.

## Time Model
- 1 day = 1 year.
- Each year lasts 24 hours.
- Rebalance window opens once at 12 hours into the year.
- Tutorial: Day 1 forced allocation ? fast-forward to Year 2 with guaranteed profit ? then normal 24h cycles.

## Simulation Model (Realistic but Simple)
- Prices evolve throughout the 24h year (mark-to-market).
- Asset returns use volatility + correlations + scenario events.
- Event impact can persist for multi-year duration.
- Cash (uninvested coins) behaves as a low-risk asset with small return and inflation drag.

## Gameplay Flow
1) **Market Map (Islands)**
   - Islands are entry points, not full gameplay.
   - Each island opens a Market Detail screen.

2) **Market Detail Screen**
   - Shows schemes or listed assets (stocks list for Stock island).
   - Displays price trend, volatility, and this-year event hooks.
   - Player chooses how many coins to allocate here.

3) **Portfolio Dashboard (New Core Screen)**
   - Shows total value, unrealized P/L, and live value updates.
   - Year timeline with remaining time + rebalance window countdown.
   - Rebalance button active only during the 12-hour window.

4) **Year-End Result**
   - Apply final P/L to coin balance.
   - Show performance summary and insights.
   - Unlock achievements and rewards.

## Rebalance Rule
- One rebalance per year, available only during the 12-hour window.
- Rebalance can shift allocations but does not reset time.
- Prevent abuse by locking repeated rapid changes.

## Events / Schemes / Realism
- Each year can have themed events (e.g., rate hikes, shortages, booms).
- Stock island supports multiple stocks with correlations.
- Use scenario packs per year to keep content fresh.

## UI Impact
- **Keep islands** as the map.
- **Add** Market Detail screens for each island.
- **Add** Portfolio Dashboard as main simulation view.
- Minimal redesign: expand depth without discarding the island concept.

## Implementation Notes (High-level)
- Add persistence for year state (start time, allocations, price path seed).
- Precompute price path per asset for a year; update on app open.
- Store rebalance-used flag and window timing.
- On year end, apply P/L to user coins.

## Open Decisions
- How strict rebalance limits should be beyond the single window.
- Event set size and update cadence.
- Balance between realism vs. fun (volatility, penalties).
