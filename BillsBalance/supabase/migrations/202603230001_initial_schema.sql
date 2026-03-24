-- Bills & Balance core schema
create extension if not exists "pgcrypto";

create type account_type as enum (
  'checking',
  'savings',
  'credit',
  'cash',
  'investment',
  'digital_wallet'
);

create type currency_type as enum (
  'USD',
  'BTC'
);

create type transaction_status as enum (
  'cleared',
  'pending'
);

create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type account_type not null,
  balance numeric(14, 2) not null default 0,
  currency currency_type not null default 'USD',
  fee_percentage numeric(5, 2) not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.bills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  amount numeric(14, 2) not null,
  due_date date not null,
  recurrence text not null default 'none',
  category text not null,
  linked_account_id uuid references public.accounts(id) on delete set null,
  is_paid boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  account_id uuid not null references public.accounts(id) on delete cascade,
  amount numeric(14, 2) not null,
  date timestamptz not null default timezone('utc', now()),
  type text not null,
  status transaction_status not null default 'pending',
  btc_sats bigint,
  btc_price numeric(14, 2),
  bill_id uuid references public.bills(id) on delete set null,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_accounts_user_id on public.accounts(user_id);
create index if not exists idx_bills_user_id on public.bills(user_id);
create index if not exists idx_bills_due_date on public.bills(due_date);
create index if not exists idx_transactions_account_id on public.transactions(account_id);
create index if not exists idx_transactions_date on public.transactions(date);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists trg_accounts_updated_at on public.accounts;
create trigger trg_accounts_updated_at
before update on public.accounts
for each row execute procedure public.set_updated_at();

drop trigger if exists trg_bills_updated_at on public.bills;
create trigger trg_bills_updated_at
before update on public.bills
for each row execute procedure public.set_updated_at();

alter table public.accounts enable row level security;
alter table public.bills enable row level security;
alter table public.transactions enable row level security;

drop policy if exists "accounts_select_own" on public.accounts;
create policy "accounts_select_own" on public.accounts
for select using (auth.uid() = user_id);

drop policy if exists "accounts_insert_own" on public.accounts;
create policy "accounts_insert_own" on public.accounts
for insert with check (auth.uid() = user_id);

drop policy if exists "accounts_update_own" on public.accounts;
create policy "accounts_update_own" on public.accounts
for update using (auth.uid() = user_id);

drop policy if exists "accounts_delete_own" on public.accounts;
create policy "accounts_delete_own" on public.accounts
for delete using (auth.uid() = user_id);

drop policy if exists "bills_select_own" on public.bills;
create policy "bills_select_own" on public.bills
for select using (auth.uid() = user_id);

drop policy if exists "bills_insert_own" on public.bills;
create policy "bills_insert_own" on public.bills
for insert with check (auth.uid() = user_id);

drop policy if exists "bills_update_own" on public.bills;
create policy "bills_update_own" on public.bills
for update using (auth.uid() = user_id);

drop policy if exists "bills_delete_own" on public.bills;
create policy "bills_delete_own" on public.bills
for delete using (auth.uid() = user_id);

drop policy if exists "transactions_select_own" on public.transactions;
create policy "transactions_select_own" on public.transactions
for select using (auth.uid() = user_id);

drop policy if exists "transactions_insert_own" on public.transactions;
create policy "transactions_insert_own" on public.transactions
for insert with check (auth.uid() = user_id);

drop policy if exists "transactions_update_own" on public.transactions;
create policy "transactions_update_own" on public.transactions
for update using (auth.uid() = user_id);

drop policy if exists "transactions_delete_own" on public.transactions;
create policy "transactions_delete_own" on public.transactions
for delete using (auth.uid() = user_id);
