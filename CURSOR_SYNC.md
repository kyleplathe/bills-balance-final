# 🚀 Project: Bills & Balance (3-Day Sprint)

## 🔄 Current Agent State
- **Last Sync:** March 23, 2026
- **Database Status:** SQL Schema Deployed (Accounts, Bills, Transactions, Categories)
- **Active Service:** EmailService (Weekly Financial Snapshot automation)
- **Latest Update:** Added `scripts/test-weekly-snapshot-email.sh` to verify Resend weekly snapshot HTML (curl + JSON payload)

## 🛠 Environment Status
- [x] Xcode Project Created
- [x] Secrets.xcconfig Verified
- [x] Physical Device Deployment Successful
- [x] UX_Reference Folder (10 Images) Ready — primary Bills screen ref: **`Bills_Main.png`** (if `.jpg` is mentioned, use the same-named **`.png`**)
- [ ] UI: Main Navigation & Bills View (Current Goal)

## ✅ Completed (Built in Sprint 1)
- [x] Database Schema & RLS Policies
- [x] LedgerService with Bill-to-Transaction sync
- [x] Bitcoin Mode: CoreMotion Shake + SwiftUI Coin Rain
- [x] Resend API Integration (EmailService.swift)

## 🚧 High Priority: Hardening (Next 24 Hours)
- [ ] **Atomic Sync:** Move Ledger logic to Supabase RPC to prevent partial data writes.
- [ ] **Auth Flow:** Connect Supabase Auth to the `EmailService` to send the "Welcome" email on sign-up.
- [ ] **Haptics:** Verify `UIImpactFeedbackGenerator` is firing on the Bitcoin shake and the Bill toggle.

## 📅 Upcoming: UI & Calendar
- [ ] Floating Nav Bar implementation (Bills, Balance, Calendar).
- [ ] Calendar Grid with "Due Date" dots.
- [ ] Landscape Split-View for Calendar.

## 📋 Project TODO List (Automated)
- [ ] **UI:** Implement Floating Nav Bar (Bills, Balance, Calendar)
- [ ] **Feature:** Shake for Bitcoin Mode (CoreMotion + CoinGecko)
- [ ] **Feature:** Two-finger drag multi-select in Balance Ledger
- [ ] **Integration:** Resend API Welcome Email on Sign-up
- [ ] **Polish:** Haptic Feedback on all Swipe/Button actions

## 🛠 Tech Stack Details
- **Supabase:** Auth + DB (RLS Enabled)
- **Currency:** USD & BTC (Sats format)
- **Architecture:** MVVM-S (Model-View-ViewModel-Service)