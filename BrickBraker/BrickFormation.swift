//
//  BrickFormation.swift
//  BrickBraker
//
//  Created by Upendra Sharma on 2/16/26.
//

import SpriteKit

// MARK: - Brick Formation Generator
// Returns a 2D grid of Bool (true = brick present) for a given stage + grid size.
// Formations progress from simple full grids → patterns → complex random shapes.

struct BrickFormation {

    /// Generate the brick-present grid for the given stage.
    /// GUARANTEE: Total brick count is strictly non-decreasing with stage.
    /// - Parameters:
    ///   - stage: 1–30
    ///   - rows: number of brick rows (grows with stage via StageParams)
    ///   - cols: number of brick columns
    /// - Returns: `[row][col]` of Bool
    static func generate(stage: Int, rows: Int, cols: Int) -> [[Bool]] {
        var rng = SeededRNG(seed: UInt64(stage * 7919 + 104729))
        let total = rows * cols

        // Minimum fill fraction grows from ~40% at stage 1 to 95% at stage 30.
        // Combined with the growing row count (3→10), total bricks always increases.
        let t = Double(max(1, min(stage, 30)) - 1) / 29.0  // 0…1
        let minFill = 0.40 + t * 0.55                        // 0.40 → 0.95
        let minBricks = Int(ceil(minFill * Double(total)))

        // Choose a visual pattern based on stage, then enforce the minimum.
        var grid: [[Bool]]

        switch stage {
        // ── Tier 1 (stages 1–5): Clean, simple shapes ──
        case 1:
            // Just the center 60% of columns, looks like a small block
            grid = centeredBlock(rows: rows, cols: cols, widthFraction: 0.6)
        case 2:
            grid = full(rows: rows, cols: cols)
        case 3:
            grid = full(rows: rows, cols: cols)
            removeCorners(&grid, depth: 1)
        case 4:
            grid = pyramid(rows: rows, cols: cols)
        case 5:
            grid = full(rows: rows, cols: cols)

        // ── Tier 2 (stages 6–10): Patterns start appearing ──
        case 6:
            grid = diamond(rows: rows, cols: cols)
            fillEdgeRows(&grid)
        case 7:
            grid = full(rows: rows, cols: cols)
            pokeCheckerHoles(&grid, skip: 3)
        case 8:
            grid = zigzag(rows: rows, cols: cols)
        case 9:
            grid = full(rows: rows, cols: cols)
            pokeRandomHoles(&grid, fraction: 0.12, rng: &rng)
        case 10:
            grid = invertedPyramid(rows: rows, cols: cols)
            fillEdgeRows(&grid)

        // ── Tier 3 (stages 11–15): Denser, trickier shapes ──
        case 11:
            grid = full(rows: rows, cols: cols)
            pokeCheckerHoles(&grid, skip: 4)
        case 12:
            grid = wave(rows: rows, cols: cols)
        case 13:
            grid = fortress(rows: rows, cols: cols)
        case 14:
            grid = full(rows: rows, cols: cols)
            pokeRandomHoles(&grid, fraction: 0.08, rng: &rng)
        case 15:
            grid = cross(rows: rows, cols: cols)
            fillEdgeRows(&grid)

        // ── Tier 4 (stages 16–20): Big + scattered patterns ──
        case 16:
            grid = full(rows: rows, cols: cols)
            punchRectangles(&grid, count: 2, rng: &rng)
        case 17:
            grid = spiral(rows: rows, cols: cols)
        case 18:
            grid = full(rows: rows, cols: cols)
            punchRectangles(&grid, count: 3, rng: &rng)
        case 19:
            grid = doubleWave(rows: rows, cols: cols)
        case 20:
            grid = full(rows: rows, cols: cols)
            pokeRandomHoles(&grid, fraction: 0.06, rng: &rng)

        // ── Tier 5 (stages 21–25): Very dense, complex ──
        case 21:
            grid = full(rows: rows, cols: cols)
            scatterGaps(&grid, count: 4, rng: &rng)
        case 22:
            grid = full(rows: rows, cols: cols)
            punchRectangles(&grid, count: 2, rng: &rng)
        case 23:
            grid = full(rows: rows, cols: cols)
            pokeRandomHoles(&grid, fraction: 0.05, rng: &rng)
        case 24:
            grid = full(rows: rows, cols: cols)
            scatterGaps(&grid, count: 3, rng: &rng)
        case 25:
            grid = full(rows: rows, cols: cols)

        // ── Tier 6 (stages 26–30): Near-full walls, maximum bricks ──
        case 26:
            grid = full(rows: rows, cols: cols)
            pokeRandomHoles(&grid, fraction: 0.04, rng: &rng)
        case 27:
            grid = full(rows: rows, cols: cols)
            scatterGaps(&grid, count: 2, rng: &rng)
        case 28:
            grid = full(rows: rows, cols: cols)
            pokeRandomHoles(&grid, fraction: 0.03, rng: &rng)
        case 29:
            grid = full(rows: rows, cols: cols)
            pokeRandomHoles(&grid, fraction: 0.02, rng: &rng)
        case 30:
            grid = full(rows: rows, cols: cols)  // Complete wall — ultimate challenge

        default:
            grid = full(rows: rows, cols: cols)
        }

        // GUARANTEE: if the pattern left fewer bricks than minBricks, fill random gaps
        enforceMinimumFill(&grid, minBricks: minBricks, rng: &rng)
        return grid
    }

    // MARK: - Base Patterns

    static func full(rows: Int, cols: Int) -> [[Bool]] {
        Array(repeating: Array(repeating: true, count: cols), count: rows)
    }

    static func centeredBlock(rows: Int, cols: Int, widthFraction: Double) -> [[Bool]] {
        let halfGap = Int(Double(cols) * (1.0 - widthFraction) / 2.0)
        return (0..<rows).map { _ in
            (0..<cols).map { c in c >= halfGap && c < cols - halfGap }
        }
    }

    static func pyramid(rows: Int, cols: Int) -> [[Bool]] {
        (0..<rows).map { r in
            let halfW = max(1, Int(CGFloat(cols) / 2.0 * CGFloat(r + 1) / CGFloat(rows)))
            let center = cols / 2
            return (0..<cols).map { c in c >= center - halfW && c <= center + halfW }
        }
    }

    static func invertedPyramid(rows: Int, cols: Int) -> [[Bool]] {
        pyramid(rows: rows, cols: cols).reversed()
    }

    static func diamond(rows: Int, cols: Int) -> [[Bool]] {
        let cr = rows / 2; let cc = cols / 2
        let maxDist = max(cr, cc)
        return (0..<rows).map { r in
            (0..<cols).map { c in abs(r - cr) + abs(c - cc) <= maxDist }
        }
    }

    static func zigzag(rows: Int, cols: Int) -> [[Bool]] {
        (0..<rows).map { r in
            let offset = (r % 2 == 0) ? 0 : 1
            return (0..<cols).map { c in (c + offset) % 3 != 0 }
        }
    }

    static func wave(rows: Int, cols: Int) -> [[Bool]] {
        (0..<rows).map { r in
            (0..<cols).map { c in
                sin(Double(c) * 0.8 + Double(r) * 0.5) > -0.3
            }
        }
    }

    static func doubleWave(rows: Int, cols: Int) -> [[Bool]] {
        (0..<rows).map { r in
            (0..<cols).map { c in
                sin(Double(c) * 0.7 + Double(r) * 0.6) + cos(Double(c) * 0.5 - Double(r) * 0.8) > -0.3
            }
        }
    }

    static func cross(rows: Int, cols: Int) -> [[Bool]] {
        let cr = rows / 2; let cc = cols / 2
        return (0..<rows).map { r in
            (0..<cols).map { c in abs(r - cr) <= 1 || abs(c - cc) <= 1 }
        }
    }

    static func fortress(rows: Int, cols: Int) -> [[Bool]] {
        (0..<rows).map { r in
            (0..<cols).map { c in
                let isBorder = r == 0 || r == rows - 1 || c == 0 || c == cols - 1
                let isPillar = (r >= rows / 3 && r <= 2 * rows / 3) &&
                               (c == cols / 3 || c == 2 * cols / 3)
                return isBorder || isPillar
            }
        }
    }

    static func spiral(rows: Int, cols: Int) -> [[Bool]] {
        (0..<rows).map { r in
            (0..<cols).map { c in
                let dy = CGFloat(r) - CGFloat(rows) / 2.0
                let dx = CGFloat(c) - CGFloat(cols) / 2.0
                return sin(atan2(dy, dx) * 2 + sqrt(dx * dx + dy * dy) * 0.8) > -0.2
            }
        }
    }

    // MARK: - Modifiers (always REMOVE bricks from a full/dense grid)

    static func removeCorners(_ grid: inout [[Bool]], depth: Int) {
        let rows = grid.count
        guard rows > 0 else { return }
        let cols = grid[0].count
        for d in 0..<depth {
            for i in 0...d {
                if d < rows && i < cols { grid[d][i] = false; grid[d][cols - 1 - i] = false }
                if rows - 1 - d >= 0 && i < cols { grid[rows - 1 - d][i] = false; grid[rows - 1 - d][cols - 1 - i] = false }
            }
        }
    }

    static func fillEdgeRows(_ grid: inout [[Bool]]) {
        guard grid.count > 0 else { return }
        let cols = grid[0].count
        for c in 0..<cols { grid[0][c] = true }
        if grid.count > 1 { for c in 0..<cols { grid[grid.count - 1][c] = true } }
    }

    static func pokeCheckerHoles(_ grid: inout [[Bool]], skip: Int) {
        for r in 0..<grid.count {
            for c in 0..<grid[r].count {
                if (r + c) % skip == 0 { grid[r][c] = false }
            }
        }
    }

    static func pokeRandomHoles(_ grid: inout [[Bool]], fraction: Double, rng: inout SeededRNG) {
        for r in 0..<grid.count {
            for c in 0..<grid[r].count where grid[r][c] {
                if rng.nextDouble() < fraction { grid[r][c] = false }
            }
        }
    }

    static func punchRectangles(_ grid: inout [[Bool]], count: Int, rng: inout SeededRNG) {
        let rows = grid.count
        guard rows > 0 else { return }
        let cols = grid[0].count
        for _ in 0..<count {
            let r0 = rng.nextInt(bound: rows)
            let c0 = rng.nextInt(bound: cols)
            let h = 1 + rng.nextInt(bound: min(2, max(1, rows - r0)))
            let w = 1 + rng.nextInt(bound: min(2, max(1, cols - c0)))
            for dr in 0..<h { for dc in 0..<w {
                if r0 + dr < rows && c0 + dc < cols { grid[r0 + dr][c0 + dc] = false }
            }}
        }
    }

    static func scatterGaps(_ grid: inout [[Bool]], count: Int, rng: inout SeededRNG) {
        let rows = grid.count
        guard rows > 0 else { return }
        let cols = grid[0].count
        for _ in 0..<count {
            let r = rng.nextInt(bound: rows)
            let c = rng.nextInt(bound: cols)
            grid[r][c] = false
        }
    }

    // MARK: - Fill Guarantee

    /// If the grid has fewer than `minBricks` true cells, randomly fill empty cells.
    static func enforceMinimumFill(_ grid: inout [[Bool]], minBricks: Int, rng: inout SeededRNG) {
        let rows = grid.count
        guard rows > 0 else { return }
        let cols = grid[0].count

        var currentCount = 0
        var emptyCells: [(Int, Int)] = []
        for r in 0..<rows {
            for c in 0..<cols {
                if grid[r][c] { currentCount += 1 }
                else { emptyCells.append((r, c)) }
            }
        }

        var needed = minBricks - currentCount
        if needed <= 0 { return }

        // Shuffle empties deterministically
        for i in stride(from: emptyCells.count - 1, through: 1, by: -1) {
            let j = rng.nextInt(bound: i + 1)
            emptyCells.swapAt(i, j)
        }

        for cell in emptyCells {
            if needed <= 0 { break }
            grid[cell.0][cell.1] = true
            needed -= 1
        }
    }
}
