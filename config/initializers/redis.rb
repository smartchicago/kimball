Redis.current = Redis.new(:host => 'localhost', :port => 6379)

# LockManager = Redlock::Client.new([ "redis://127.0.0.1:6379"])


# first_try_lock_info = LockManager.lock("resource_key", 2000)
# second_try_lock_info = LockManager.lock("resource_key", 2000)

# # it prints lock info {validity: 1987, resource: "resource_key", value: "generated_uuid4"}
# p first_try_lock_info
# # it prints false
# p second_try_lock_info

# # Unlocking
# LockManager.unlock(first_try_lock_info)
# second_try_lock_info = LockManager.lock("resource_key", 2000)

# # now it prints lock info
# p second_try_lock_info

# LockManager.lock("resource key", 3000, extend: second_try_lock_info)
