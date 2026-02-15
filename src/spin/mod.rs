use core::{
    cell::UnsafeCell,
    ops::{Deref, DerefMut},
    sync::atomic::{AtomicBool, Ordering},
};

pub struct Spinlock<T: ?Sized> {
    lock: AtomicBool,
    data: UnsafeCell<T>,
}

impl<T> Spinlock<T> {
    pub const fn new(user_data: T) -> Self {
        Self {
            lock: AtomicBool::new(false),
            data: UnsafeCell::new(user_data),
        }
    }
}

impl<T: ?Sized> Spinlock<T> {
    pub fn lock(&self) -> MutexGuard<'_, T> {
        while self
            .lock
            .compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed)
            .is_err()
        {
            core::hint::spin_loop();
        }
        let data = unsafe { &mut *self.data.get() };
        MutexGuard { lock: self, data }
    }

    pub fn unlock(&self) {
        self.lock.store(false, Ordering::Relaxed);
    }
}

/// for static global
unsafe impl<T> Sync for Spinlock<T> {}

pub struct MutexGuard<'a, T: ?Sized + 'a> {
    lock: &'a Spinlock<T>,
    data: &'a mut T,
}

impl<'a, T: ?Sized> Drop for MutexGuard<'a, T> {
    fn drop(&mut self) {
        self.lock.unlock();
    }
}

impl<'a, T: ?Sized> Deref for MutexGuard<'a, T> {
    type Target = T;
    fn deref(&self) -> &Self::Target {
        self.data
    }
}

impl<'a, T: ?Sized> DerefMut for MutexGuard<'a, T> {
    fn deref_mut(&mut self) -> &mut T {
        self.data
    }
}
