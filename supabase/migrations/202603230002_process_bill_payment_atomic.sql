create or replace function public.process_bill_payment_atomic(
  p_bill_id uuid,
  p_account_id uuid
)
returns void
language plpgsql
security invoker
as $$
declare
  v_user_id uuid := auth.uid();
  v_bill_amount numeric(14, 2);
  v_bill_is_paid boolean;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select amount, is_paid
  into v_bill_amount, v_bill_is_paid
  from public.bills
  where id = p_bill_id
    and user_id = v_user_id
    and linked_account_id = p_account_id
  for update;

  if not found then
    raise exception 'Bill not found for current user/account';
  end if;

  if v_bill_is_paid then
    raise exception 'Bill is already paid';
  end if;

  perform 1
  from public.accounts
  where id = p_account_id
    and user_id = v_user_id
  for update;

  if not found then
    raise exception 'Account not found for current user';
  end if;

  update public.bills
  set is_paid = true
  where id = p_bill_id
    and user_id = v_user_id;

  insert into public.transactions (
    user_id,
    account_id,
    amount,
    date,
    type,
    status,
    bill_id
  )
  values (
    v_user_id,
    p_account_id,
    v_bill_amount,
    timezone('utc', now()),
    'bill_payment',
    'cleared',
    p_bill_id
  );

  update public.accounts
  set balance = balance - v_bill_amount
  where id = p_account_id
    and user_id = v_user_id;
end;
$$;
