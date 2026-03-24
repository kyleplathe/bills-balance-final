# 🚀 Project: Bills & Balance (Day 2 In Progress)

## 🔄 Current Agent State
- **Last Sync:** 2026-03-23T20:11 local — Liquid Glass capsule nav shipped; build verified (`xcodebuild`).
- **Git Status:** Atomic commits per checklist; sync file updated with each completed `[x]`.
- **Environment:** Xcode Project builds to physical iPhone; `Secrets.xcconfig` active.
- **Database:** Supabase Schema Deployed; `DatabaseManager` & `LedgerService` verified.
- **Next `[ ]` priority:** Overhaul BillsView with `Theme.swift` card depth (no default Lists).

## ✅ Completed (Sprint 1)
- [x] Database Schema & RLS Policies.
- [x] LedgerService (Bill-to-Transaction sync).
- [x] Bitcoin Mode (CoreMotion Shake + SwiftUI Coin Rain).
- [x] Resend API Integration (`EmailService.swift` + Weekly Snapshot script).
- [x] Theme System (`Theme.swift` with Liquid Glass card styles).

## 📋 TODO: Day 2 (High Priority)
- [x] **UI:** Implement Floating "Liquid Glass" Capsule Nav Bar (MainContainerView).
- [ ] **UI:** Overhaul BillsView with `Theme.swift` card depth (No default Lists).
- [ ] **Feature:** Build `BalanceView` Account Grid (Checking, Savings, BTC).
- [ ] **Feature:** Multi-Select & Two-finger drag gesture for Transaction Ledger.
- [ ] **Hardening:** Move Ledger logic to Supabase RPC for atomic writes.

## 🛠 Tech Stack & Rules
- **Stack:** SwiftUI (MVVM-S), Supabase, Resend, CoinGecko.
- **Rule 1:** READ this file before every task.
- **Rule 2:** PERFORM an atomic git commit after every [x] update.
- **Rule 3:** Reference `UX_Reference` images for all UI tasks.
