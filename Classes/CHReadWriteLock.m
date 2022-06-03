/*
 * CHReadWriteLock.m
 * appbuildr
 *
 * Created on 6/11/12.
 * 
 * Copyright (c) 2012 Socialize, Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

//CHReadWriteLock.m
#import "CHReadWriteLock.h"

static CHReadWriteLock* lock = nil;

@implementation CHReadWriteLock

- (id) init {
	if (self = [super init]) {
		pthread_rwlock_init(&lock, NULL);
	}
	return self;
}

- (void) dealloc {
	pthread_rwlock_destroy(&lock);
	[super dealloc];
}

- (void) finalize {
	pthread_rwlock_destroy(&lock);
	[super finalize];
}

- (void) lock {
	pthread_rwlock_rdlock(&lock);
}

- (void) unlock {
	pthread_rwlock_unlock(&lock);
}

- (void) lockForWriting {
	pthread_rwlock_wrlock(&lock);
}

- (BOOL) tryLock {
	return (pthread_rwlock_tryrdlock(&lock) == 0);
}

- (BOOL) tryLockForWriting {
	return (pthread_rwlock_trywrlock(&lock) == 0);
}

+(CHReadWriteLock*)sharedLock
{
    @synchronized(self)
    {
        if(lock == nil)
            lock = [CHReadWriteLock new];
    }
    return lock;
}

@end
