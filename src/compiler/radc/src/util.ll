; ModuleID = 'ref_util'
source_filename = "ref_util"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@str_lit = private unnamed_addr constant [3 x i8] c"w+\00", align 1
@str_lit.1 = private unnamed_addr constant [2 x i8] c"r\00", align 1
@str_lit.2 = private unnamed_addr constant [2 x i8] c"w\00", align 1
@str_lit.3 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1
@str_lit.4 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1
@str_lit.5 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@str_lit.6 = private unnamed_addr constant [3 x i8] c"rb\00", align 1
@str_lit.7 = private unnamed_addr constant [3 x i8] c"wb\00", align 1

declare i32 @printf(ptr, ...)

declare i32 @snprintf(ptr, i64, ptr, ...)

declare i32 @puts(ptr)

declare void @exit(i32)

declare ptr @memcpy(ptr, ptr, i64)

declare ptr @memset(ptr, i32, i64)

declare ptr @malloc(i64)

declare void @free(ptr)

declare ptr @realloc(ptr, i64)

declare i64 @write(i32, ptr, i64)

declare i64 @read(i32, ptr, i64)

declare ptr @fopen(ptr, ptr)

declare i32 @fclose(ptr)

declare i64 @fread(ptr, i64, i64, ptr)

declare i64 @fwrite(ptr, i64, i64, ptr)

declare i32 @fseek(ptr, i64, i32)

declare i64 @ftell(ptr)

declare i32 @fflush(ptr)

declare i32 @remove(ptr)

declare ptr @getenv(ptr)

declare i32 @setenv(ptr, ptr, i32)

declare i32 @system(ptr)

declare i32 @getpid()

declare i32 @usleep(i32)

declare i64 @time(ptr)

declare i32 @clock_gettime(i32, ptr)

declare i32 @socket(i32, i32, i32)

declare i32 @connect(i32, ptr, i32)

declare i32 @bind(i32, ptr, i32)

declare i32 @listen(i32, i32)

declare i32 @accept(i32, ptr, ptr)

declare i64 @send(i32, ptr, i64, i32)

declare i64 @recv(i32, ptr, i64, i32)

declare i32 @close(i32)

declare i32 @pthread_create(ptr, ptr, ptr, ptr)

declare i32 @pthread_join(i64, ptr)

declare i32 @pthread_mutex_init(ptr, ptr)

declare i32 @pthread_mutex_lock(ptr)

declare i32 @pthread_mutex_unlock(ptr)

declare i32 @pthread_mutex_destroy(ptr)

declare i32 @pthread_cond_init(ptr, ptr)

declare i32 @pthread_cond_wait(ptr, ptr)

declare i32 @pthread_cond_signal(ptr)

declare i32 @pthread_cond_broadcast(ptr)

declare i32 @pthread_cond_destroy(ptr)

declare i32 @pthread_rwlock_init(ptr, ptr)

declare i32 @pthread_rwlock_rdlock(ptr)

declare i32 @pthread_rwlock_wrlock(ptr)

declare i32 @pthread_rwlock_unlock(ptr)

declare i32 @pthread_rwlock_destroy(ptr)

declare i32 @sched_yield()

declare i32 @epoll_create1(i32)

declare i32 @epoll_ctl(i32, i32, i32, ptr)

declare i32 @epoll_wait(i32, ptr, i32, i32)

declare i32 @pipe(ptr)

define i1 @AtomicBool__compare_exchange({ ptr } %0, i1 %1, i1 %2) {
bb0:
  %_0 = alloca i1, align 1
  %self = alloca { ptr }, align 8
  %expected = alloca i1, align 1
  %desired = alloca i1, align 1
  %exp = alloca i32, align 4
  %des = alloca i32, align 4
  %old = alloca i32, align 4
  %_7 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i1 %1, ptr %expected, align 1
  store i1 %2, ptr %desired, align 1
  %load__2 = load i1, ptr %expected, align 1
  switch i1 %load__2, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  store i32 1, ptr %exp, align 4
  br label %bb3

bb2:                                              ; preds = %bb0
  store i32 0, ptr %exp, align 4
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %load__3 = load i1, ptr %desired, align 1
  switch i1 %load__3, label %bb5 [
    i1 true, label %bb4
  ]

bb4:                                              ; preds = %bb3
  store i32 1, ptr %des, align 4
  br label %bb6

bb5:                                              ; preds = %bb3
  store i32 0, ptr %des, align 4
  br label %bb6

bb6:                                              ; preds = %bb5, %bb4
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_7, align 8
  %load__7 = load ptr, ptr %_7, align 8
  %load__4 = load i32, ptr %exp, align 4
  %load__5 = load i32, ptr %des, align 4
  %3 = cmpxchg ptr %load__7, i32 %load__4, i32 %load__5 seq_cst seq_cst, align 4
  %cmpxchg_val = extractvalue { i32, i1 } %3, 0
  store i32 %cmpxchg_val, ptr %old, align 4
  br label %bb7

bb7:                                              ; preds = %bb6
  %load__6 = load i32, ptr %old, align 4
  %netmp = icmp ne i32 %load__6, 0
  store i1 %netmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define void @AtomicBool__destroy({ ptr } %0) {
bb0:
  %self = alloca { ptr }, align 8
  %_2 = alloca ptr, align 8
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  store ptr %load__3, ptr %_2, align 8
  %load__2 = load ptr, ptr %_2, align 8
  call void @free(ptr %load__2)
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define i1 @AtomicBool__load({ ptr } %0) {
bb0:
  %_0 = alloca i1, align 1
  %self = alloca { ptr }, align 8
  %v = alloca i32, align 4
  %_3 = alloca ptr, align 8
  %_4 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_4, align 8
  %load__4 = load ptr, ptr %_4, align 8
  store ptr %load__4, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %1 = atomicrmw or ptr %load__3, i32 0 seq_cst, align 4
  store i32 %1, ptr %v, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__2 = load i32, ptr %v, align 4
  %netmp = icmp ne i32 %load__2, 0
  store i1 %netmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define { ptr } @AtomicBool__new(i1 %0) {
bb0:
  %_0 = alloca { ptr }, align 8
  %val = alloca i1, align 1
  %p = alloca ptr, align 8
  %_3 = alloca ptr, align 8
  %int_val = alloca i32, align 4
  store i1 %0, ptr %val, align 1
  %calltmp = call ptr @malloc(i64 4)
  store ptr %calltmp, ptr %_3, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__3 = load ptr, ptr %_3, align 8
  store ptr %load__3, ptr %p, align 8
  %load__1 = load i1, ptr %val, align 1
  switch i1 %load__1, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  store i32 1, ptr %int_val, align 4
  br label %bb4

bb3:                                              ; preds = %bb1
  store i32 0, ptr %int_val, align 4
  br label %bb4

bb4:                                              ; preds = %bb3, %bb2
  %load__2 = load ptr, ptr %p, align 8
  %load__4 = load i32, ptr %int_val, align 4
  %1 = atomicrmw xchg ptr %load__2, i32 %load__4 seq_cst, align 4
  br label %bb5

bb5:                                              ; preds = %bb4
  %load__21 = load ptr, ptr %p, align 8
  %f_gep_0 = getelementptr inbounds nuw { ptr }, ptr %_0, i32 0, i32 0
  store ptr %load__21, ptr %f_gep_0, align 8
  %ret_val = load { ptr }, ptr %_0, align 8
  ret { ptr } %ret_val
}

define void @AtomicBool__store({ ptr } %0, i1 %1) {
bb0:
  %self = alloca { ptr }, align 8
  %val = alloca i1, align 1
  %int_val = alloca i32, align 4
  %_4 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i1 %1, ptr %val, align 1
  %load__2 = load i1, ptr %val, align 1
  switch i1 %load__2, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  store i32 1, ptr %int_val, align 4
  br label %bb3

bb2:                                              ; preds = %bb0
  store i32 0, ptr %int_val, align 4
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_4, align 8
  %load__4 = load ptr, ptr %_4, align 8
  %load__3 = load i32, ptr %int_val, align 4
  %2 = atomicrmw xchg ptr %load__4, i32 %load__3 seq_cst, align 4
  br label %bb4

bb4:                                              ; preds = %bb3
  ret void
}

define i1 @AtomicBool__swap({ ptr } %0, i1 %1) {
bb0:
  %_0 = alloca i1, align 1
  %self = alloca { ptr }, align 8
  %val = alloca i1, align 1
  %int_val = alloca i32, align 4
  %old = alloca i32, align 4
  %_5 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i1 %1, ptr %val, align 1
  %load__2 = load i1, ptr %val, align 1
  switch i1 %load__2, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  store i32 1, ptr %int_val, align 4
  br label %bb3

bb2:                                              ; preds = %bb0
  store i32 0, ptr %int_val, align 4
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_5, align 8
  %load__5 = load ptr, ptr %_5, align 8
  %load__3 = load i32, ptr %int_val, align 4
  %2 = atomicrmw xchg ptr %load__5, i32 %load__3 seq_cst, align 4
  store i32 %2, ptr %old, align 4
  br label %bb4

bb4:                                              ; preds = %bb3
  %load__4 = load i32, ptr %old, align 4
  %netmp = icmp ne i32 %load__4, 0
  store i1 %netmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define i32 @AtomicI32__compare_exchange({ ptr } %0, i32 %1, i32 %2) {
bb0:
  %_0 = alloca i32, align 4
  %self = alloca { ptr }, align 8
  %expected = alloca i32, align 4
  %desired = alloca i32, align 4
  %_4 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i32 %1, ptr %expected, align 4
  store i32 %2, ptr %desired, align 4
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_4, align 8
  %load__4 = load ptr, ptr %_4, align 8
  %load__2 = load i32, ptr %expected, align 4
  %load__3 = load i32, ptr %desired, align 4
  %3 = cmpxchg ptr %load__4, i32 %load__2, i32 %load__3 seq_cst seq_cst, align 4
  %cmpxchg_val = extractvalue { i32, i1 } %3, 0
  store i32 %cmpxchg_val, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

define void @AtomicI32__destroy({ ptr } %0) {
bb0:
  %self = alloca { ptr }, align 8
  %_2 = alloca ptr, align 8
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  store ptr %load__3, ptr %_2, align 8
  %load__2 = load ptr, ptr %_2, align 8
  call void @free(ptr %load__2)
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define i32 @AtomicI32__fetch_add({ ptr } %0, i32 %1) {
bb0:
  %_0 = alloca i32, align 4
  %self = alloca { ptr }, align 8
  %val = alloca i32, align 4
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i32 %1, ptr %val, align 4
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %load__2 = load i32, ptr %val, align 4
  %2 = atomicrmw add ptr %load__3, i32 %load__2 seq_cst, align 4
  store i32 %2, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

define i32 @AtomicI32__fetch_sub({ ptr } %0, i32 %1) {
bb0:
  %_0 = alloca i32, align 4
  %self = alloca { ptr }, align 8
  %val = alloca i32, align 4
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i32 %1, ptr %val, align 4
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %load__2 = load i32, ptr %val, align 4
  %2 = atomicrmw sub ptr %load__3, i32 %load__2 seq_cst, align 4
  store i32 %2, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

define i32 @AtomicI32__load({ ptr } %0) {
bb0:
  %_0 = alloca i32, align 4
  %self = alloca { ptr }, align 8
  %_2 = alloca ptr, align 8
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  store ptr %load__3, ptr %_2, align 8
  %load__2 = load ptr, ptr %_2, align 8
  %1 = atomicrmw or ptr %load__2, i32 0 seq_cst, align 4
  store i32 %1, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

define { ptr } @AtomicI32__new(i32 %0) {
bb0:
  %_0 = alloca { ptr }, align 8
  %val = alloca i32, align 4
  %p = alloca ptr, align 8
  %_3 = alloca ptr, align 8
  store i32 %0, ptr %val, align 4
  %calltmp = call ptr @malloc(i64 4)
  store ptr %calltmp, ptr %_3, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__3 = load ptr, ptr %_3, align 8
  store ptr %load__3, ptr %p, align 8
  %load__2 = load ptr, ptr %p, align 8
  %load__1 = load i32, ptr %val, align 4
  %1 = atomicrmw xchg ptr %load__2, i32 %load__1 seq_cst, align 4
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__21 = load ptr, ptr %p, align 8
  %f_gep_0 = getelementptr inbounds nuw { ptr }, ptr %_0, i32 0, i32 0
  store ptr %load__21, ptr %f_gep_0, align 8
  %ret_val = load { ptr }, ptr %_0, align 8
  ret { ptr } %ret_val
}

define void @AtomicI32__store({ ptr } %0, i32 %1) {
bb0:
  %self = alloca { ptr }, align 8
  %val = alloca i32, align 4
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i32 %1, ptr %val, align 4
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %load__2 = load i32, ptr %val, align 4
  %2 = atomicrmw xchg ptr %load__3, i32 %load__2 seq_cst, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define i32 @AtomicI32__swap({ ptr } %0, i32 %1) {
bb0:
  %_0 = alloca i32, align 4
  %self = alloca { ptr }, align 8
  %val = alloca i32, align 4
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i32 %1, ptr %val, align 4
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %load__2 = load i32, ptr %val, align 4
  %2 = atomicrmw xchg ptr %load__3, i32 %load__2 seq_cst, align 4
  store i32 %2, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

define i64 @AtomicI64__compare_exchange({ ptr } %0, i64 %1, i64 %2) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { ptr }, align 8
  %expected = alloca i64, align 8
  %desired = alloca i64, align 8
  %_4 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i64 %1, ptr %expected, align 8
  store i64 %2, ptr %desired, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_4, align 8
  %load__4 = load ptr, ptr %_4, align 8
  %load__2 = load i64, ptr %expected, align 8
  %load__3 = load i64, ptr %desired, align 8
  %3 = cmpxchg ptr %load__4, i64 %load__2, i64 %load__3 seq_cst seq_cst, align 8
  %cmpxchg_val = extractvalue { i64, i1 } %3, 0
  store i64 %cmpxchg_val, ptr %_0, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define void @AtomicI64__destroy({ ptr } %0) {
bb0:
  %self = alloca { ptr }, align 8
  %_2 = alloca ptr, align 8
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  store ptr %load__3, ptr %_2, align 8
  %load__2 = load ptr, ptr %_2, align 8
  call void @free(ptr %load__2)
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define i64 @AtomicI64__fetch_add({ ptr } %0, i64 %1) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { ptr }, align 8
  %val = alloca i64, align 8
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i64 %1, ptr %val, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %load__2 = load i64, ptr %val, align 8
  %2 = atomicrmw add ptr %load__3, i64 %load__2 seq_cst, align 8
  store i64 %2, ptr %_0, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define i64 @AtomicI64__fetch_sub({ ptr } %0, i64 %1) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { ptr }, align 8
  %val = alloca i64, align 8
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i64 %1, ptr %val, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %load__2 = load i64, ptr %val, align 8
  %2 = atomicrmw sub ptr %load__3, i64 %load__2 seq_cst, align 8
  store i64 %2, ptr %_0, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define i64 @AtomicI64__load({ ptr } %0) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { ptr }, align 8
  %_2 = alloca ptr, align 8
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  store ptr %load__3, ptr %_2, align 8
  %load__2 = load ptr, ptr %_2, align 8
  %1 = atomicrmw or ptr %load__2, i64 0 seq_cst, align 8
  store i64 %1, ptr %_0, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define { ptr } @AtomicI64__new(i64 %0) {
bb0:
  %_0 = alloca { ptr }, align 8
  %val = alloca i64, align 8
  %p = alloca ptr, align 8
  %_3 = alloca ptr, align 8
  store i64 %0, ptr %val, align 8
  %calltmp = call ptr @malloc(i64 8)
  store ptr %calltmp, ptr %_3, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__3 = load ptr, ptr %_3, align 8
  store ptr %load__3, ptr %p, align 8
  %load__2 = load ptr, ptr %p, align 8
  %load__1 = load i64, ptr %val, align 8
  %1 = atomicrmw xchg ptr %load__2, i64 %load__1 seq_cst, align 8
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__21 = load ptr, ptr %p, align 8
  %f_gep_0 = getelementptr inbounds nuw { ptr }, ptr %_0, i32 0, i32 0
  store ptr %load__21, ptr %f_gep_0, align 8
  %ret_val = load { ptr }, ptr %_0, align 8
  ret { ptr } %ret_val
}

define void @AtomicI64__store({ ptr } %0, i64 %1) {
bb0:
  %self = alloca { ptr }, align 8
  %val = alloca i64, align 8
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i64 %1, ptr %val, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %load__2 = load i64, ptr %val, align 8
  %2 = atomicrmw xchg ptr %load__3, i64 %load__2 seq_cst, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define i64 @AtomicI64__swap({ ptr } %0, i64 %1) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { ptr }, align 8
  %val = alloca i64, align 8
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  store i64 %1, ptr %val, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %load__2 = load i64, ptr %val, align 8
  %2 = atomicrmw xchg ptr %load__3, i64 %load__2 seq_cst, align 8
  store i64 %2, ptr %_0, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define i64 @AtomicUsize__compare_exchange({ ptr } %0, i64 %1, i64 %2) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { ptr }, align 8
  %expected = alloca i64, align 8
  %desired = alloca i64, align 8
  %_4 = alloca i64, align 8
  %_5 = alloca ptr, align 8
  %_6 = alloca i64, align 8
  %_7 = alloca i64, align 8
  store { ptr } %0, ptr %self, align 8
  store i64 %1, ptr %expected, align 8
  store i64 %2, ptr %desired, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_5, align 8
  %load__2 = load i64, ptr %expected, align 8
  store i64 %load__2, ptr %_6, align 8
  %load__3 = load i64, ptr %desired, align 8
  store i64 %load__3, ptr %_7, align 8
  %load__5 = load ptr, ptr %_5, align 8
  %load__6 = load i64, ptr %_6, align 8
  %load__7 = load i64, ptr %_7, align 8
  %3 = cmpxchg ptr %load__5, i64 %load__6, i64 %load__7 seq_cst seq_cst, align 8
  %cmpxchg_val = extractvalue { i64, i1 } %3, 0
  store i64 %cmpxchg_val, ptr %_4, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__4 = load i64, ptr %_4, align 8
  store i64 %load__4, ptr %_0, align 8
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define void @AtomicUsize__destroy({ ptr } %0) {
bb0:
  %self = alloca { ptr }, align 8
  %_2 = alloca ptr, align 8
  %_3 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  store ptr %load__3, ptr %_2, align 8
  %load__2 = load ptr, ptr %_2, align 8
  call void @free(ptr %load__2)
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define i64 @AtomicUsize__fetch_add({ ptr } %0, i64 %1) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { ptr }, align 8
  %val = alloca i64, align 8
  %_3 = alloca i64, align 8
  %_4 = alloca ptr, align 8
  %_5 = alloca i64, align 8
  store { ptr } %0, ptr %self, align 8
  store i64 %1, ptr %val, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_4, align 8
  %load__2 = load i64, ptr %val, align 8
  store i64 %load__2, ptr %_5, align 8
  %load__4 = load ptr, ptr %_4, align 8
  %load__5 = load i64, ptr %_5, align 8
  %2 = atomicrmw add ptr %load__4, i64 %load__5 seq_cst, align 8
  store i64 %2, ptr %_3, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__3 = load i64, ptr %_3, align 8
  store i64 %load__3, ptr %_0, align 8
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define i64 @AtomicUsize__fetch_sub({ ptr } %0, i64 %1) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { ptr }, align 8
  %val = alloca i64, align 8
  %_3 = alloca i64, align 8
  %_4 = alloca ptr, align 8
  %_5 = alloca i64, align 8
  store { ptr } %0, ptr %self, align 8
  store i64 %1, ptr %val, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_4, align 8
  %load__2 = load i64, ptr %val, align 8
  store i64 %load__2, ptr %_5, align 8
  %load__4 = load ptr, ptr %_4, align 8
  %load__5 = load i64, ptr %_5, align 8
  %2 = atomicrmw sub ptr %load__4, i64 %load__5 seq_cst, align 8
  store i64 %2, ptr %_3, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__3 = load i64, ptr %_3, align 8
  store i64 %load__3, ptr %_0, align 8
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define i64 @AtomicUsize__load({ ptr } %0) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { ptr }, align 8
  %_2 = alloca i64, align 8
  %_3 = alloca ptr, align 8
  %_4 = alloca ptr, align 8
  store { ptr } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_4, align 8
  %load__4 = load ptr, ptr %_4, align 8
  store ptr %load__4, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %1 = atomicrmw or ptr %load__3, i64 0 seq_cst, align 8
  store i64 %1, ptr %_2, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__2 = load i64, ptr %_2, align 8
  store i64 %load__2, ptr %_0, align 8
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define { ptr } @AtomicUsize__new(i64 %0) {
bb0:
  %_0 = alloca { ptr }, align 8
  %val = alloca i64, align 8
  %p = alloca ptr, align 8
  %_3 = alloca ptr, align 8
  %_5 = alloca i64, align 8
  store i64 %0, ptr %val, align 8
  %calltmp = call ptr @malloc(i64 8)
  store ptr %calltmp, ptr %_3, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__3 = load ptr, ptr %_3, align 8
  store ptr %load__3, ptr %p, align 8
  %load__1 = load i64, ptr %val, align 8
  store i64 %load__1, ptr %_5, align 8
  %load__2 = load ptr, ptr %p, align 8
  %load__5 = load i64, ptr %_5, align 8
  %1 = atomicrmw xchg ptr %load__2, i64 %load__5 seq_cst, align 8
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__21 = load ptr, ptr %p, align 8
  %f_gep_0 = getelementptr inbounds nuw { ptr }, ptr %_0, i32 0, i32 0
  store ptr %load__21, ptr %f_gep_0, align 8
  %ret_val = load { ptr }, ptr %_0, align 8
  ret { ptr } %ret_val
}

define void @AtomicUsize__store({ ptr } %0, i64 %1) {
bb0:
  %self = alloca { ptr }, align 8
  %val = alloca i64, align 8
  %_3 = alloca ptr, align 8
  %_4 = alloca i64, align 8
  store { ptr } %0, ptr %self, align 8
  store i64 %1, ptr %val, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__2 = load i64, ptr %val, align 8
  store i64 %load__2, ptr %_4, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %load__4 = load i64, ptr %_4, align 8
  %2 = atomicrmw xchg ptr %load__3, i64 %load__4 seq_cst, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define i64 @AtomicUsize__swap({ ptr } %0, i64 %1) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { ptr }, align 8
  %val = alloca i64, align 8
  %_3 = alloca i64, align 8
  %_4 = alloca ptr, align 8
  %_5 = alloca i64, align 8
  store { ptr } %0, ptr %self, align 8
  store i64 %1, ptr %val, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr }, ptr %self, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_4, align 8
  %load__2 = load i64, ptr %val, align 8
  store i64 %load__2, ptr %_5, align 8
  %load__4 = load ptr, ptr %_4, align 8
  %load__5 = load i64, ptr %_5, align 8
  %2 = atomicrmw xchg ptr %load__4, i64 %load__5 seq_cst, align 8
  store i64 %2, ptr %_3, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__3 = load i64, ptr %_3, align 8
  store i64 %load__3, ptr %_0, align 8
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define i64 @Duration__as_millis({ i64, i32 } %0) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { i64, i32 }, align 8
  %_2 = alloca i64, align 8
  %_3 = alloca i64, align 8
  %_4 = alloca i64, align 8
  %_5 = alloca i64, align 8
  %_6 = alloca i32, align 4
  store { i64, i32 } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { i64, i32 }, ptr %self, i32 0, i32 0
  %load__1.0 = load i64, ptr %struct_f_0, align 8
  store i64 %load__1.0, ptr %_3, align 8
  %load__3 = load i64, ptr %_3, align 8
  %multmp = mul i64 %load__3, 1000
  store i64 %multmp, ptr %_2, align 8
  %struct_f_1 = getelementptr inbounds nuw { i64, i32 }, ptr %self, i32 0, i32 1
  %load__1.1 = load i32, ptr %struct_f_1, align 4
  store i32 %load__1.1, ptr %_6, align 4
  %load__6 = load i32, ptr %_6, align 4
  %casttmp = sext i32 %load__6 to i64
  store i64 %casttmp, ptr %_5, align 8
  %load__5 = load i64, ptr %_5, align 8
  %divtmp = sdiv i64 %load__5, 1000000
  store i64 %divtmp, ptr %_4, align 8
  %load__2 = load i64, ptr %_2, align 8
  %load__4 = load i64, ptr %_4, align 8
  %addtmp = add i64 %load__2, %load__4
  store i64 %addtmp, ptr %_0, align 8
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define i64 @Duration__as_secs({ i64, i32 } %0) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { i64, i32 }, align 8
  store { i64, i32 } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { i64, i32 }, ptr %self, i32 0, i32 0
  %load__1.0 = load i64, ptr %struct_f_0, align 8
  store i64 %load__1.0, ptr %_0, align 8
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define { i64, i32 } @Duration__from_millis(i64 %0) {
bb0:
  %_0 = alloca { i64, i32 }, align 8
  %millis = alloca i64, align 8
  %secs = alloca i64, align 8
  %rem_ms = alloca i64, align 8
  %nanos = alloca i32, align 4
  %_5 = alloca i32, align 4
  store i64 %0, ptr %millis, align 8
  %load__1 = load i64, ptr %millis, align 8
  %divtmp = sdiv i64 %load__1, 1000
  store i64 %divtmp, ptr %secs, align 8
  %load__11 = load i64, ptr %millis, align 8
  %remtmp = srem i64 %load__11, 1000
  store i64 %remtmp, ptr %rem_ms, align 8
  %load__3 = load i64, ptr %rem_ms, align 8
  %casttmp = trunc i64 %load__3 to i32
  store i32 %casttmp, ptr %_5, align 4
  %load__5 = load i32, ptr %_5, align 4
  %multmp = mul i32 %load__5, 1000000
  store i32 %multmp, ptr %nanos, align 4
  %load__2 = load i64, ptr %secs, align 8
  %f_gep_0 = getelementptr inbounds nuw { i64, i32 }, ptr %_0, i32 0, i32 0
  store i64 %load__2, ptr %f_gep_0, align 8
  %load__4 = load i32, ptr %nanos, align 4
  %f_gep_1 = getelementptr inbounds nuw { i64, i32 }, ptr %_0, i32 0, i32 1
  store i32 %load__4, ptr %f_gep_1, align 4
  %ret_val = load { i64, i32 }, ptr %_0, align 8
  ret { i64, i32 } %ret_val
}

define { i64, i32 } @Duration__from_secs(i64 %0) {
bb0:
  %_0 = alloca { i64, i32 }, align 8
  %secs = alloca i64, align 8
  store i64 %0, ptr %secs, align 8
  %load__1 = load i64, ptr %secs, align 8
  %f_gep_0 = getelementptr inbounds nuw { i64, i32 }, ptr %_0, i32 0, i32 0
  store i64 %load__1, ptr %f_gep_0, align 8
  %f_gep_1 = getelementptr inbounds nuw { i64, i32 }, ptr %_0, i32 0, i32 1
  store i32 0, ptr %f_gep_1, align 4
  %ret_val = load { i64, i32 }, ptr %_0, align 8
  ret { i64, i32 } %ret_val
}

define void @File__close(ptr %0) {
bb0:
  %_2 = alloca i1, align 1
  %_3 = alloca i32, align 4
  %_4 = alloca ptr, align 8
  %struct_f_1 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i1, ptr %struct_f_1, align 1
  store i1 %load__1.1, ptr %_2, align 1
  %load__2 = load i1, ptr %_2, align 1
  switch i1 %load__2, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %struct_f_0 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_4, align 8
  %load__4 = load ptr, ptr %_4, align 8
  %calltmp = call i32 @fclose(ptr %load__4)
  store i32 %calltmp, ptr %_3, align 4
  br label %bb4

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb4, %bb2
  ret void

bb4:                                              ; preds = %bb1
  %struct_f_11 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 1
  store i1 false, ptr %struct_f_11, align 1
  br label %bb3
}

define { i32, { ptr, i1 } } @File__create(ptr %0) {
bb0:
  %_0 = alloca { i32, { ptr, i1 } }, align 8
  %path = alloca ptr, align 8
  store ptr %0, ptr %path, align 8
  %load__1 = load ptr, ptr %path, align 8
  %calltmp = call { i32, { ptr, i1 } } @File__open(ptr %load__1, ptr @str_lit)
  store { i32, { ptr, i1 } } %calltmp, ptr %_0, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load { i32, { ptr, i1 } }, ptr %_0, align 8
  ret { i32, { ptr, i1 } } %ret_val
}

define void @File__drop(ptr %0) {
bb0:
  call void @File__close(ptr %0)
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define void @File__flush(ptr %0) {
bb0:
  %_2 = alloca i1, align 1
  %_3 = alloca ptr, align 8
  %struct_f_1 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i1, ptr %struct_f_1, align 1
  store i1 %load__1.1, ptr %_2, align 1
  %load__2 = load i1, ptr %_2, align 1
  switch i1 %load__2, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %struct_f_0 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_3, align 8
  %load__3 = load ptr, ptr %_3, align 8
  %calltmp = call i32 @fflush(ptr %load__3)
  br label %bb4

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb4, %bb2
  ret void

bb4:                                              ; preds = %bb1
  br label %bb3
}

define { i32, { ptr, i1 } } @File__open(ptr %0, ptr %1) {
bb0:
  %_0 = alloca { i32, { ptr, i1 } }, align 8
  %path = alloca ptr, align 8
  %mode = alloca ptr, align 8
  %fp = alloca ptr, align 8
  %_4 = alloca i1, align 1
  %_5 = alloca i64, align 8
  %_6 = alloca { ptr, i1 }, align 8
  store ptr %0, ptr %path, align 8
  store ptr %1, ptr %mode, align 8
  %load__1 = load ptr, ptr %path, align 8
  %load__2 = load ptr, ptr %mode, align 8
  %calltmp = call ptr @fopen(ptr %load__1, ptr %load__2)
  store ptr %calltmp, ptr %fp, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__3 = load ptr, ptr %fp, align 8
  %ptr2int = ptrtoint ptr %load__3 to i64
  store i64 %ptr2int, ptr %_5, align 8
  %load__5 = load i64, ptr %_5, align 8
  %eqtmp = icmp eq i64 %load__5, 0
  store i1 %eqtmp, ptr %_4, align 1
  %load__4 = load i1, ptr %_4, align 1
  switch i1 %load__4, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  %f_gep_0 = getelementptr inbounds nuw { i32, { ptr, i1 } }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_0, align 4
  %f_gep_1 = getelementptr inbounds nuw { i32, { ptr, i1 } }, ptr %_0, i32 0, i32 1
  store { ptr, i1 } zeroinitializer, ptr %f_gep_1, align 8
  br label %bb4

bb3:                                              ; preds = %bb1
  %load__31 = load ptr, ptr %fp, align 8
  %f_gep_02 = getelementptr inbounds nuw { ptr, i1 }, ptr %_6, i32 0, i32 0
  store ptr %load__31, ptr %f_gep_02, align 8
  %f_gep_13 = getelementptr inbounds nuw { ptr, i1 }, ptr %_6, i32 0, i32 1
  store i1 true, ptr %f_gep_13, align 1
  %f_gep_04 = getelementptr inbounds nuw { i32, { ptr, i1 } }, ptr %_0, i32 0, i32 0
  store i32 1, ptr %f_gep_04, align 4
  %load__6 = load { ptr, i1 }, ptr %_6, align 8
  %f_gep_15 = getelementptr inbounds nuw { i32, { ptr, i1 } }, ptr %_0, i32 0, i32 1
  store { ptr, i1 } %load__6, ptr %f_gep_15, align 8
  br label %bb4

bb4:                                              ; preds = %bb3, %bb2
  %ret_val = load { i32, { ptr, i1 } }, ptr %_0, align 8
  ret { i32, { ptr, i1 } } %ret_val
}

define { i32, { ptr, i1 } } @File__open_read(ptr %0) {
bb0:
  %_0 = alloca { i32, { ptr, i1 } }, align 8
  %path = alloca ptr, align 8
  store ptr %0, ptr %path, align 8
  %load__1 = load ptr, ptr %path, align 8
  %calltmp = call { i32, { ptr, i1 } } @File__open(ptr %load__1, ptr @str_lit.1)
  store { i32, { ptr, i1 } } %calltmp, ptr %_0, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load { i32, { ptr, i1 } }, ptr %_0, align 8
  ret { i32, { ptr, i1 } } %ret_val
}

define { i32, { ptr, i1 } } @File__open_write(ptr %0) {
bb0:
  %_0 = alloca { i32, { ptr, i1 } }, align 8
  %path = alloca ptr, align 8
  store ptr %0, ptr %path, align 8
  %load__1 = load ptr, ptr %path, align 8
  %calltmp = call { i32, { ptr, i1 } } @File__open(ptr %load__1, ptr @str_lit.2)
  store { i32, { ptr, i1 } } %calltmp, ptr %_0, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load { i32, { ptr, i1 } }, ptr %_0, align 8
  ret { i32, { ptr, i1 } } %ret_val
}

define { { ptr, i64, i64 } } @File__read_to_string(ptr %0) {
bb0:
  %_0 = alloca { { ptr, i64, i64 } }, align 8
  %result = alloca { { ptr, i64, i64 } }, align 8
  %_4 = alloca i1, align 1
  %_5 = alloca i1, align 1
  %_6 = alloca i32, align 4
  %_7 = alloca ptr, align 8
  %file_size = alloca i64, align 8
  %_9 = alloca i64, align 8
  %_10 = alloca ptr, align 8
  %_11 = alloca i32, align 4
  %_12 = alloca ptr, align 8
  %_14 = alloca i1, align 1
  %raw = alloca ptr, align 8
  %_16 = alloca i64, align 8
  %n_read = alloca i64, align 8
  %_18 = alloca i64, align 8
  %_19 = alloca ptr, align 8
  %p = alloca ptr, align 8
  %i = alloca i64, align 8
  %_23 = alloca i1, align 1
  %_25 = alloca i8, align 1
  %calltmp = call { { ptr, i64, i64 } } @String__new()
  store { { ptr, i64, i64 } } %calltmp, ptr %result, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %struct_f_1 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i1, ptr %struct_f_1, align 1
  store i1 %load__1.1, ptr %_5, align 1
  %load__5 = load i1, ptr %_5, align 1
  %nottmp = xor i1 %load__5, true
  store i1 %nottmp, ptr %_4, align 1
  %load__4 = load i1, ptr %_4, align 1
  switch i1 %load__4, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  %load__2 = load { { ptr, i64, i64 } }, ptr %result, align 8
  store { { ptr, i64, i64 } } %load__2, ptr %_0, align 8
  %ret_val = load { { ptr, i64, i64 } }, ptr %_0, align 8
  ret { { ptr, i64, i64 } } %ret_val

bb3:                                              ; preds = %bb1
  br label %bb4

bb4:                                              ; preds = %bb3
  %struct_f_0 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_7, align 8
  %load__7 = load ptr, ptr %_7, align 8
  %calltmp1 = call i32 @fseek(ptr %load__7, i64 0, i32 2)
  store i32 %calltmp1, ptr %_6, align 4
  br label %bb5

bb5:                                              ; preds = %bb4
  %struct_f_02 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 0
  %load__1.03 = load ptr, ptr %struct_f_02, align 8
  store ptr %load__1.03, ptr %_10, align 8
  %load__10 = load ptr, ptr %_10, align 8
  %calltmp4 = call i64 @ftell(ptr %load__10)
  store i64 %calltmp4, ptr %_9, align 8
  br label %bb6

bb6:                                              ; preds = %bb5
  %load__9 = load i64, ptr %_9, align 8
  store i64 %load__9, ptr %file_size, align 8
  %struct_f_05 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 0
  %load__1.06 = load ptr, ptr %struct_f_05, align 8
  store ptr %load__1.06, ptr %_12, align 8
  %load__12 = load ptr, ptr %_12, align 8
  %calltmp7 = call i32 @fseek(ptr %load__12, i64 0, i32 0)
  store i32 %calltmp7, ptr %_11, align 4
  br label %bb7

bb7:                                              ; preds = %bb6
  %load__8 = load i64, ptr %file_size, align 8
  %eqtmp = icmp eq i64 %load__8, 0
  store i1 %eqtmp, ptr %_14, align 1
  %load__14 = load i1, ptr %_14, align 1
  switch i1 %load__14, label %bb9 [
    i1 true, label %bb8
  ]

bb8:                                              ; preds = %bb7
  %load__28 = load { { ptr, i64, i64 } }, ptr %result, align 8
  store { { ptr, i64, i64 } } %load__28, ptr %_0, align 8
  %ret_val9 = load { { ptr, i64, i64 } }, ptr %_0, align 8
  ret { { ptr, i64, i64 } } %ret_val9

bb9:                                              ; preds = %bb7
  br label %bb10

bb10:                                             ; preds = %bb9
  %load__810 = load i64, ptr %file_size, align 8
  %addtmp = add i64 %load__810, 1
  store i64 %addtmp, ptr %_16, align 8
  %load__16 = load i64, ptr %_16, align 8
  %calltmp11 = call ptr @malloc(i64 %load__16)
  store ptr %calltmp11, ptr %raw, align 8
  br label %bb11

bb11:                                             ; preds = %bb10
  %struct_f_012 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 0
  %load__1.013 = load ptr, ptr %struct_f_012, align 8
  store ptr %load__1.013, ptr %_19, align 8
  %load__15 = load ptr, ptr %raw, align 8
  %load__814 = load i64, ptr %file_size, align 8
  %load__19 = load ptr, ptr %_19, align 8
  %calltmp15 = call i64 @fread(ptr %load__15, i64 1, i64 %load__814, ptr %load__19)
  store i64 %calltmp15, ptr %_18, align 8
  br label %bb12

bb12:                                             ; preds = %bb11
  %load__18 = load i64, ptr %_18, align 8
  store i64 %load__18, ptr %n_read, align 8
  %load__1516 = load ptr, ptr %raw, align 8
  store ptr %load__1516, ptr %p, align 8
  %idx_load = load i64, ptr %n_read, align 8
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  store i8 0, ptr %ptr_idx, align 1
  store i64 0, ptr %i, align 8
  br label %bb13

bb13:                                             ; preds = %bb16, %bb12
  %load__21 = load i64, ptr %i, align 8
  %load__17 = load i64, ptr %n_read, align 8
  %lttmp = icmp slt i64 %load__21, %load__17
  store i1 %lttmp, ptr %_23, align 1
  %load__23 = load i1, ptr %_23, align 1
  switch i1 %load__23, label %bb15 [
    i1 true, label %bb14
  ]

bb14:                                             ; preds = %bb13
  %idx_load17 = load i64, ptr %i, align 8
  %raw_ptr_load18 = load ptr, ptr %p, align 8
  %ptr_idx19 = getelementptr i8, ptr %raw_ptr_load18, i64 %idx_load17
  %"load__20[_21]" = load i8, ptr %ptr_idx19, align 1
  store i8 %"load__20[_21]", ptr %_25, align 1
  %load__25 = load i8, ptr %_25, align 1
  call void @String__push_byte(ptr %result, i8 %load__25)
  br label %bb16

bb15:                                             ; preds = %bb13
  %load__1520 = load ptr, ptr %raw, align 8
  call void @free(ptr %load__1520)
  br label %bb17

bb16:                                             ; preds = %bb14
  %load__2121 = load i64, ptr %i, align 8
  %addtmp22 = add i64 %load__2121, 1
  store i64 %addtmp22, ptr %i, align 8
  br label %bb13

bb17:                                             ; preds = %bb15
  %load__223 = load { { ptr, i64, i64 } }, ptr %result, align 8
  store { { ptr, i64, i64 } } %load__223, ptr %_0, align 8
  %ret_val24 = load { { ptr, i64, i64 } }, ptr %_0, align 8
  ret { { ptr, i64, i64 } } %ret_val24
}

define i1 @File__write_str(ptr %0, ptr %1) {
bb0:
  %_0 = alloca i1, align 1
  %s = alloca ptr, align 8
  %_4 = alloca i1, align 1
  %_5 = alloca i1, align 1
  %p = alloca ptr, align 8
  %len = alloca i64, align 8
  %_9 = alloca i1, align 1
  %_10 = alloca i8, align 1
  %written = alloca i64, align 8
  %_12 = alloca ptr, align 8
  %_13 = alloca ptr, align 8
  %_14 = alloca i64, align 8
  store ptr %1, ptr %s, align 8
  %struct_f_1 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i1, ptr %struct_f_1, align 1
  store i1 %load__1.1, ptr %_5, align 1
  %load__5 = load i1, ptr %_5, align 1
  %nottmp = xor i1 %load__5, true
  store i1 %nottmp, ptr %_4, align 1
  %load__4 = load i1, ptr %_4, align 1
  switch i1 %load__4, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  store i1 false, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb2
  %load__2 = load ptr, ptr %s, align 8
  store ptr %load__2, ptr %p, align 8
  store i64 0, ptr %len, align 8
  br label %bb4

bb4:                                              ; preds = %bb5, %bb3
  %idx_load = load i64, ptr %len, align 8
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__6[_7]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__6[_7]", ptr %_10, align 1
  %load__10 = load i8, ptr %_10, align 1
  %netmp = icmp ne i8 %load__10, 0
  store i1 %netmp, ptr %_9, align 1
  %load__9 = load i1, ptr %_9, align 1
  switch i1 %load__9, label %bb6 [
    i1 true, label %bb5
  ]

bb5:                                              ; preds = %bb4
  %load__7 = load i64, ptr %len, align 8
  %addtmp = add i64 %load__7, 1
  store i64 %addtmp, ptr %len, align 8
  br label %bb4

bb6:                                              ; preds = %bb4
  %load__6 = load ptr, ptr %p, align 8
  store ptr %load__6, ptr %_12, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_13, align 8
  %load__12 = load ptr, ptr %_12, align 8
  %load__71 = load i64, ptr %len, align 8
  %load__13 = load ptr, ptr %_13, align 8
  %calltmp = call i64 @fwrite(ptr %load__12, i64 1, i64 %load__71, ptr %load__13)
  store i64 %calltmp, ptr %written, align 8
  br label %bb7

bb7:                                              ; preds = %bb6
  %load__72 = load i64, ptr %len, align 8
  store i64 %load__72, ptr %_14, align 8
  %load__11 = load i64, ptr %written, align 8
  %load__14 = load i64, ptr %_14, align 8
  %eqtmp = icmp eq i64 %load__11, %load__14
  store i1 %eqtmp, ptr %_0, align 1
  %ret_val3 = load i1, ptr %_0, align 1
  ret i1 %ret_val3
}

define ptr @GlobalAllocator__allocate(ptr %0, i64 %1) {
bb0:
  %_0 = alloca ptr, align 8
  %size = alloca i64, align 8
  store i64 %1, ptr %size, align 8
  %load__2 = load i64, ptr %size, align 8
  %calltmp = call ptr @malloc(i64 %load__2)
  store ptr %calltmp, ptr %_0, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load ptr, ptr %_0, align 8
  ret ptr %ret_val
}

define void @GlobalAllocator__deallocate(ptr %0, ptr %1, i64 %2) {
bb0:
  %ptr = alloca ptr, align 8
  %size = alloca i64, align 8
  store ptr %1, ptr %ptr, align 8
  store i64 %2, ptr %size, align 8
  %load__2 = load ptr, ptr %ptr, align 8
  call void @free(ptr %load__2)
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define ptr @GlobalAllocator__reallocate(ptr %0, ptr %1, i64 %2, i64 %3) {
bb0:
  %_0 = alloca ptr, align 8
  %ptr = alloca ptr, align 8
  %old_size = alloca i64, align 8
  %new_size = alloca i64, align 8
  store ptr %1, ptr %ptr, align 8
  store i64 %2, ptr %old_size, align 8
  store i64 %3, ptr %new_size, align 8
  %load__2 = load ptr, ptr %ptr, align 8
  %load__4 = load i64, ptr %new_size, align 8
  %calltmp = call ptr @realloc(ptr %load__2, i64 %load__4)
  store ptr %calltmp, ptr %_0, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load ptr, ptr %_0, align 8
  ret ptr %ret_val
}

define i1 @HashMap__contains_key__val_bool({ ptr, i64, i64 } %0, i32 %1) {
bb0:
  %_0 = alloca i1, align 1
  %self = alloca { ptr, i64, i64 }, align 8
  %key = alloca i32, align 4
  %_3 = alloca { i32, i1 }, align 8
  %_4 = alloca i32, align 4
  %_5 = alloca i32, align 4
  store { ptr, i64, i64 } %0, ptr %self, align 8
  store i32 %1, ptr %key, align 4
  %load__1 = load { ptr, i64, i64 }, ptr %self, align 8
  %load__2 = load i32, ptr %key, align 4
  %calltmp = call { i32, i32 } @HashMap__get__val_val({ ptr, i64, i64 } %load__1, i32 %load__2)
  store { i32, i32 } %calltmp, ptr %_3, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  br label %bb3

bb2:                                              ; preds = %bb10, %bb9, %bb7
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val

bb3:                                              ; preds = %bb1
  %tag_gep = getelementptr inbounds nuw { i32, i1 }, ptr %_3, i32 0, i32 0
  %tag_val = load i32, ptr %tag_gep, align 4
  store i32 %tag_val, ptr %_4, align 4
  %load__4 = load i32, ptr %_4, align 4
  switch i32 %load__4, label %bb4 [
    i32 1, label %bb8
  ]

bb4:                                              ; preds = %bb3
  %tag_gep1 = getelementptr inbounds nuw { i32, i1 }, ptr %_3, i32 0, i32 0
  %tag_val2 = load i32, ptr %tag_gep1, align 4
  store i32 %tag_val2, ptr %_5, align 4
  %load__5 = load i32, ptr %_5, align 4
  switch i32 %load__5, label %bb5 [
    i32 0, label %bb9
  ]

bb5:                                              ; preds = %bb4
  br label %bb10

bb6:                                              ; No predecessors!
  unreachable

bb7:                                              ; preds = %bb8
  store i1 true, ptr %_0, align 1
  br label %bb2

bb8:                                              ; preds = %bb3
  br label %bb7

bb9:                                              ; preds = %bb4
  store i1 false, ptr %_0, align 1
  br label %bb2

bb10:                                             ; preds = %bb5
  store i1 false, ptr %_0, align 1
  br label %bb2
}

define void @HashMap__drop__val_bool(ptr %0) {
bb0:
  %_2 = alloca i1, align 1
  %_3 = alloca i64, align 8
  %_5 = alloca ptr, align 8
  %_6 = alloca ptr, align 8
  %struct_f_1 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i64, ptr %struct_f_1, align 8
  store i64 %load__1.1, ptr %_3, align 8
  %load__3 = load i64, ptr %_3, align 8
  %gttmp = icmp sgt i64 %load__3, 0
  store i1 %gttmp, ptr %_2, align 1
  %load__2 = load i1, ptr %_2, align 1
  switch i1 %load__2, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %struct_f_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_6, align 8
  %load__6 = load ptr, ptr %_6, align 8
  store ptr %load__6, ptr %_5, align 8
  %load__5 = load ptr, ptr %_5, align 8
  call void @free(ptr %load__5)
  br label %bb4

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb4, %bb2
  ret void

bb4:                                              ; preds = %bb1
  %struct_f_11 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  store i64 0, ptr %struct_f_11, align 8
  %struct_f_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  store i64 0, ptr %struct_f_2, align 8
  br label %bb3
}

define { i32, i32 } @HashMap__get__val_val({ ptr, i64, i64 } %0, i32 %1) {
bb0:
  %_0 = alloca { i32, i32 }, align 8
  %self = alloca { ptr, i64, i64 }, align 8
  %key = alloca i32, align 4
  %_4 = alloca i1, align 1
  %_5 = alloca i64, align 8
  %idx = alloca i64, align 8
  %_7 = alloca i64, align 8
  %_8 = alloca i64, align 8
  %count = alloca i64, align 8
  %_11 = alloca i1, align 1
  %_12 = alloca i64, align 8
  %_14 = alloca i1, align 1
  %_15 = alloca i1, align 1
  %_17 = alloca i1, align 1
  %_18 = alloca i32, align 4
  %_19 = alloca i32, align 4
  %_20 = alloca i64, align 8
  %_21 = alloca i64, align 8
  store { ptr, i64, i64 } %0, ptr %self, align 8
  store i32 %1, ptr %key, align 4
  %struct_f_1 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 1
  %load__1.1 = load i64, ptr %struct_f_1, align 8
  store i64 %load__1.1, ptr %_5, align 8
  %load__5 = load i64, ptr %_5, align 8
  %eqtmp = icmp eq i64 %load__5, 0
  store i1 %eqtmp, ptr %_4, align 1
  %load__4 = load i1, ptr %_4, align 1
  switch i1 %load__4, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %f_gep_0 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_0, align 4
  %f_gep_1 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 1
  store i32 0, ptr %f_gep_1, align 4
  %ret_val = load { i32, i32 }, ptr %_0, align 4
  ret { i32, i32 } %ret_val

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb2
  %load__2 = load i32, ptr %key, align 4
  %casttmp = sext i32 %load__2 to i64
  store i64 %casttmp, ptr %_7, align 8
  %struct_f_11 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 1
  %load__1.12 = load i64, ptr %struct_f_11, align 8
  store i64 %load__1.12, ptr %_8, align 8
  %load__7 = load i64, ptr %_7, align 8
  %load__8 = load i64, ptr %_8, align 8
  %remtmp = srem i64 %load__7, %load__8
  store i64 %remtmp, ptr %idx, align 8
  store i64 0, ptr %count, align 8
  br label %bb4

bb4:                                              ; preds = %bb12, %bb3
  %struct_f_13 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 1
  %load__1.14 = load i64, ptr %struct_f_13, align 8
  store i64 %load__1.14, ptr %_12, align 8
  %load__9 = load i64, ptr %count, align 8
  %load__12 = load i64, ptr %_12, align 8
  %lttmp = icmp slt i64 %load__9, %load__12
  store i1 %lttmp, ptr %_11, align 1
  %load__11 = load i1, ptr %_11, align 1
  switch i1 %load__11, label %bb6 [
    i1 true, label %bb5
  ]

bb5:                                              ; preds = %bb4
  %struct_f_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 0
  %idx_load = load i64, ptr %idx, align 8
  %raw_ptr_load = load ptr, ptr %struct_f_0, align 8
  %ptr_idx = getelementptr { i32, i32, i1 }, ptr %raw_ptr_load, i64 %idx_load
  %struct_f_2 = getelementptr inbounds nuw { i32, i32, i1 }, ptr %ptr_idx, i32 0, i32 2
  %"load__1.0[_6].2" = load i1, ptr %struct_f_2, align 1
  store i1 %"load__1.0[_6].2", ptr %_15, align 1
  %load__15 = load i1, ptr %_15, align 1
  %nottmp = xor i1 %load__15, true
  store i1 %nottmp, ptr %_14, align 1
  %load__14 = load i1, ptr %_14, align 1
  switch i1 %load__14, label %bb8 [
    i1 true, label %bb7
  ]

bb6:                                              ; preds = %bb4
  %f_gep_05 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_05, align 4
  %f_gep_16 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 1
  store i32 0, ptr %f_gep_16, align 4
  %ret_val7 = load { i32, i32 }, ptr %_0, align 4
  ret { i32, i32 } %ret_val7

bb7:                                              ; preds = %bb5
  %f_gep_08 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_08, align 4
  %f_gep_19 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 1
  store i32 0, ptr %f_gep_19, align 4
  %ret_val10 = load { i32, i32 }, ptr %_0, align 4
  ret { i32, i32 } %ret_val10

bb8:                                              ; preds = %bb5
  br label %bb9

bb9:                                              ; preds = %bb8
  %struct_f_011 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 0
  %idx_load12 = load i64, ptr %idx, align 8
  %raw_ptr_load13 = load ptr, ptr %struct_f_011, align 8
  %ptr_idx14 = getelementptr { i32, i32, i1 }, ptr %raw_ptr_load13, i64 %idx_load12
  %struct_f_015 = getelementptr inbounds nuw { i32, i32, i1 }, ptr %ptr_idx14, i32 0, i32 0
  %"load__1.0[_6].0" = load i32, ptr %struct_f_015, align 4
  store i32 %"load__1.0[_6].0", ptr %_18, align 4
  %load__18 = load i32, ptr %_18, align 4
  %load__216 = load i32, ptr %key, align 4
  %eqtmp17 = icmp eq i32 %load__18, %load__216
  store i1 %eqtmp17, ptr %_17, align 1
  %load__17 = load i1, ptr %_17, align 1
  switch i1 %load__17, label %bb11 [
    i1 true, label %bb10
  ]

bb10:                                             ; preds = %bb9
  %struct_f_018 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 0
  %idx_load19 = load i64, ptr %idx, align 8
  %raw_ptr_load20 = load ptr, ptr %struct_f_018, align 8
  %ptr_idx21 = getelementptr { i32, i32, i1 }, ptr %raw_ptr_load20, i64 %idx_load19
  %struct_f_122 = getelementptr inbounds nuw { i32, i32, i1 }, ptr %ptr_idx21, i32 0, i32 1
  %"load__1.0[_6].1" = load i32, ptr %struct_f_122, align 4
  store i32 %"load__1.0[_6].1", ptr %_19, align 4
  %f_gep_023 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 0
  store i32 1, ptr %f_gep_023, align 4
  %load__19 = load i32, ptr %_19, align 4
  %f_gep_124 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 1
  store i32 %load__19, ptr %f_gep_124, align 4
  %ret_val25 = load { i32, i32 }, ptr %_0, align 4
  ret { i32, i32 } %ret_val25

bb11:                                             ; preds = %bb9
  br label %bb12

bb12:                                             ; preds = %bb11
  %load__6 = load i64, ptr %idx, align 8
  %addtmp = add i64 %load__6, 1
  store i64 %addtmp, ptr %_20, align 8
  %struct_f_126 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 1
  %load__1.127 = load i64, ptr %struct_f_126, align 8
  store i64 %load__1.127, ptr %_21, align 8
  %load__20 = load i64, ptr %_20, align 8
  %load__21 = load i64, ptr %_21, align 8
  %remtmp28 = srem i64 %load__20, %load__21
  store i64 %remtmp28, ptr %idx, align 8
  %load__929 = load i64, ptr %count, align 8
  %addtmp30 = add i64 %load__929, 1
  store i64 %addtmp30, ptr %count, align 8
  br label %bb4
}

define { i32, i1 } @HashMap__insert__val_bool(ptr %0, i32 %1, i1 %2) {
bb0:
  %_0 = alloca { i32, i1 }, align 8
  %key = alloca i32, align 4
  %val = alloca i1, align 1
  %_5 = alloca i1, align 1
  %_6 = alloca i64, align 8
  %initial_cap = alloca i64, align 8
  %entry_size = alloca i64, align 8
  %_9 = alloca i64, align 8
  %_10 = alloca i64, align 8
  %_11 = alloca i64, align 8
  %raw = alloca ptr, align 8
  %_13 = alloca i64, align 8
  %i = alloca i64, align 8
  %_15 = alloca i1, align 1
  %idx = alloca i64, align 8
  %_17 = alloca i64, align 8
  %_18 = alloca i64, align 8
  %count = alloca i64, align 8
  %_21 = alloca i1, align 1
  %_22 = alloca i64, align 8
  %_24 = alloca i1, align 1
  %_25 = alloca i1, align 1
  %_26 = alloca i64, align 8
  %_28 = alloca i1, align 1
  %_29 = alloca i32, align 4
  %old_val = alloca i1, align 1
  %_31 = alloca i64, align 8
  %_32 = alloca i64, align 8
  store i32 %1, ptr %key, align 4
  store i1 %2, ptr %val, align 1
  %struct_f_1 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i64, ptr %struct_f_1, align 8
  store i64 %load__1.1, ptr %_6, align 8
  %load__6 = load i64, ptr %_6, align 8
  %eqtmp = icmp eq i64 %load__6, 0
  store i1 %eqtmp, ptr %_5, align 1
  %load__5 = load i1, ptr %_5, align 1
  switch i1 %load__5, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  store i64 16, ptr %initial_cap, align 8
  store i64 8, ptr %_10, align 8
  br label %bb4

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb9, %bb2
  %load__2 = load i32, ptr %key, align 4
  %casttmp = sext i32 %load__2 to i64
  store i64 %casttmp, ptr %_17, align 8
  %struct_f_11 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.12 = load i64, ptr %struct_f_11, align 8
  store i64 %load__1.12, ptr %_18, align 8
  %load__17 = load i64, ptr %_17, align 8
  %load__18 = load i64, ptr %_18, align 8
  %remtmp = srem i64 %load__17, %load__18
  store i64 %remtmp, ptr %idx, align 8
  store i64 0, ptr %count, align 8
  br label %bb10

bb4:                                              ; preds = %bb1
  store i64 1, ptr %_11, align 8
  br label %bb5

bb5:                                              ; preds = %bb4
  %load__10 = load i64, ptr %_10, align 8
  %load__11 = load i64, ptr %_11, align 8
  %addtmp = add i64 %load__10, %load__11
  store i64 %addtmp, ptr %_9, align 8
  %load__9 = load i64, ptr %_9, align 8
  %addtmp3 = add i64 %load__9, 8
  store i64 %addtmp3, ptr %entry_size, align 8
  %load__7 = load i64, ptr %initial_cap, align 8
  %load__8 = load i64, ptr %entry_size, align 8
  %multmp = mul i64 %load__7, %load__8
  store i64 %multmp, ptr %_13, align 8
  %load__13 = load i64, ptr %_13, align 8
  %calltmp = call ptr @malloc(i64 %load__13)
  store ptr %calltmp, ptr %raw, align 8
  br label %bb6

bb6:                                              ; preds = %bb5
  %load__12 = load ptr, ptr %raw, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  store ptr %load__12, ptr %struct_f_0, align 8
  %load__74 = load i64, ptr %initial_cap, align 8
  %struct_f_15 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  store i64 %load__74, ptr %struct_f_15, align 8
  store i64 0, ptr %i, align 8
  br label %bb7

bb7:                                              ; preds = %bb8, %bb6
  %load__14 = load i64, ptr %i, align 8
  %load__76 = load i64, ptr %initial_cap, align 8
  %lttmp = icmp slt i64 %load__14, %load__76
  store i1 %lttmp, ptr %_15, align 1
  %load__15 = load i1, ptr %_15, align 1
  switch i1 %load__15, label %bb9 [
    i1 true, label %bb8
  ]

bb8:                                              ; preds = %bb7
  %struct_f_07 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %idx_load = load i64, ptr %i, align 8
  %raw_ptr_load = load ptr, ptr %struct_f_07, align 8
  %ptr_idx = getelementptr { i32, i1, i1 }, ptr %raw_ptr_load, i64 %idx_load
  %struct_f_2 = getelementptr inbounds nuw { i32, i1, i1 }, ptr %ptr_idx, i32 0, i32 2
  store i1 false, ptr %struct_f_2, align 1
  %load__148 = load i64, ptr %i, align 8
  %addtmp9 = add i64 %load__148, 1
  store i64 %addtmp9, ptr %i, align 8
  br label %bb7

bb9:                                              ; preds = %bb7
  br label %bb3

bb10:                                             ; preds = %bb18, %bb3
  %struct_f_110 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.111 = load i64, ptr %struct_f_110, align 8
  store i64 %load__1.111, ptr %_22, align 8
  %load__19 = load i64, ptr %count, align 8
  %load__22 = load i64, ptr %_22, align 8
  %lttmp12 = icmp slt i64 %load__19, %load__22
  store i1 %lttmp12, ptr %_21, align 1
  %load__21 = load i1, ptr %_21, align 1
  switch i1 %load__21, label %bb12 [
    i1 true, label %bb11
  ]

bb11:                                             ; preds = %bb10
  %struct_f_013 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %idx_load14 = load i64, ptr %idx, align 8
  %raw_ptr_load15 = load ptr, ptr %struct_f_013, align 8
  %ptr_idx16 = getelementptr { i32, i1, i1 }, ptr %raw_ptr_load15, i64 %idx_load14
  %struct_f_217 = getelementptr inbounds nuw { i32, i1, i1 }, ptr %ptr_idx16, i32 0, i32 2
  %"load__1.0[_16].2" = load i1, ptr %struct_f_217, align 1
  store i1 %"load__1.0[_16].2", ptr %_25, align 1
  %load__25 = load i1, ptr %_25, align 1
  %nottmp = xor i1 %load__25, true
  store i1 %nottmp, ptr %_24, align 1
  %load__24 = load i1, ptr %_24, align 1
  switch i1 %load__24, label %bb14 [
    i1 true, label %bb13
  ]

bb12:                                             ; preds = %bb10
  %f_gep_0 = getelementptr inbounds nuw { i32, i1 }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_0, align 4
  %f_gep_1 = getelementptr inbounds nuw { i32, i1 }, ptr %_0, i32 0, i32 1
  store i1 false, ptr %f_gep_1, align 1
  %ret_val = load { i32, i1 }, ptr %_0, align 4
  ret { i32, i1 } %ret_val

bb13:                                             ; preds = %bb11
  %load__218 = load i32, ptr %key, align 4
  %struct_f_019 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %idx_load20 = load i64, ptr %idx, align 8
  %raw_ptr_load21 = load ptr, ptr %struct_f_019, align 8
  %ptr_idx22 = getelementptr { i32, i1, i1 }, ptr %raw_ptr_load21, i64 %idx_load20
  %struct_f_023 = getelementptr inbounds nuw { i32, i1, i1 }, ptr %ptr_idx22, i32 0, i32 0
  store i32 %load__218, ptr %struct_f_023, align 4
  %load__3 = load i1, ptr %val, align 1
  %struct_f_024 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %idx_load25 = load i64, ptr %idx, align 8
  %raw_ptr_load26 = load ptr, ptr %struct_f_024, align 8
  %ptr_idx27 = getelementptr { i32, i1, i1 }, ptr %raw_ptr_load26, i64 %idx_load25
  %struct_f_128 = getelementptr inbounds nuw { i32, i1, i1 }, ptr %ptr_idx27, i32 0, i32 1
  store i1 %load__3, ptr %struct_f_128, align 1
  %struct_f_029 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %idx_load30 = load i64, ptr %idx, align 8
  %raw_ptr_load31 = load ptr, ptr %struct_f_029, align 8
  %ptr_idx32 = getelementptr { i32, i1, i1 }, ptr %raw_ptr_load31, i64 %idx_load30
  %struct_f_233 = getelementptr inbounds nuw { i32, i1, i1 }, ptr %ptr_idx32, i32 0, i32 2
  store i1 true, ptr %struct_f_233, align 1
  %struct_f_234 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  %load__1.2 = load i64, ptr %struct_f_234, align 8
  store i64 %load__1.2, ptr %_26, align 8
  %load__26 = load i64, ptr %_26, align 8
  %addtmp35 = add i64 %load__26, 1
  %struct_f_236 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  store i64 %addtmp35, ptr %struct_f_236, align 8
  %f_gep_037 = getelementptr inbounds nuw { i32, i1 }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_037, align 4
  %f_gep_138 = getelementptr inbounds nuw { i32, i1 }, ptr %_0, i32 0, i32 1
  store i1 false, ptr %f_gep_138, align 1
  %ret_val39 = load { i32, i1 }, ptr %_0, align 4
  ret { i32, i1 } %ret_val39

bb14:                                             ; preds = %bb11
  br label %bb15

bb15:                                             ; preds = %bb14
  %struct_f_040 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %idx_load41 = load i64, ptr %idx, align 8
  %raw_ptr_load42 = load ptr, ptr %struct_f_040, align 8
  %ptr_idx43 = getelementptr { i32, i1, i1 }, ptr %raw_ptr_load42, i64 %idx_load41
  %struct_f_044 = getelementptr inbounds nuw { i32, i1, i1 }, ptr %ptr_idx43, i32 0, i32 0
  %"load__1.0[_16].0" = load i32, ptr %struct_f_044, align 4
  store i32 %"load__1.0[_16].0", ptr %_29, align 4
  %load__29 = load i32, ptr %_29, align 4
  %load__245 = load i32, ptr %key, align 4
  %eqtmp46 = icmp eq i32 %load__29, %load__245
  store i1 %eqtmp46, ptr %_28, align 1
  %load__28 = load i1, ptr %_28, align 1
  switch i1 %load__28, label %bb17 [
    i1 true, label %bb16
  ]

bb16:                                             ; preds = %bb15
  %struct_f_047 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %idx_load48 = load i64, ptr %idx, align 8
  %raw_ptr_load49 = load ptr, ptr %struct_f_047, align 8
  %ptr_idx50 = getelementptr { i32, i1, i1 }, ptr %raw_ptr_load49, i64 %idx_load48
  %struct_f_151 = getelementptr inbounds nuw { i32, i1, i1 }, ptr %ptr_idx50, i32 0, i32 1
  %"load__1.0[_16].1" = load i1, ptr %struct_f_151, align 1
  store i1 %"load__1.0[_16].1", ptr %old_val, align 1
  %load__352 = load i1, ptr %val, align 1
  %struct_f_053 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %idx_load54 = load i64, ptr %idx, align 8
  %raw_ptr_load55 = load ptr, ptr %struct_f_053, align 8
  %ptr_idx56 = getelementptr { i32, i1, i1 }, ptr %raw_ptr_load55, i64 %idx_load54
  %struct_f_157 = getelementptr inbounds nuw { i32, i1, i1 }, ptr %ptr_idx56, i32 0, i32 1
  store i1 %load__352, ptr %struct_f_157, align 1
  %f_gep_058 = getelementptr inbounds nuw { i32, i1 }, ptr %_0, i32 0, i32 0
  store i32 1, ptr %f_gep_058, align 4
  %load__30 = load i1, ptr %old_val, align 1
  %f_gep_159 = getelementptr inbounds nuw { i32, i1 }, ptr %_0, i32 0, i32 1
  store i1 %load__30, ptr %f_gep_159, align 1
  %ret_val60 = load { i32, i1 }, ptr %_0, align 4
  ret { i32, i1 } %ret_val60

bb17:                                             ; preds = %bb15
  br label %bb18

bb18:                                             ; preds = %bb17
  %load__16 = load i64, ptr %idx, align 8
  %addtmp61 = add i64 %load__16, 1
  store i64 %addtmp61, ptr %_31, align 8
  %struct_f_162 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.163 = load i64, ptr %struct_f_162, align 8
  store i64 %load__1.163, ptr %_32, align 8
  %load__31 = load i64, ptr %_31, align 8
  %load__32 = load i64, ptr %_32, align 8
  %remtmp64 = srem i64 %load__31, %load__32
  store i64 %remtmp64, ptr %idx, align 8
  %load__1965 = load i64, ptr %count, align 8
  %addtmp66 = add i64 %load__1965, 1
  store i64 %addtmp66, ptr %count, align 8
  br label %bb10
}

define i1 @HashMap__is_empty__val_bool({ ptr, i64, i64 } %0) {
bb0:
  %_0 = alloca i1, align 1
  %self = alloca { ptr, i64, i64 }, align 8
  %_2 = alloca i64, align 8
  store { ptr, i64, i64 } %0, ptr %self, align 8
  %struct_f_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 2
  %load__1.2 = load i64, ptr %struct_f_2, align 8
  store i64 %load__1.2, ptr %_2, align 8
  %load__2 = load i64, ptr %_2, align 8
  %eqtmp = icmp eq i64 %load__2, 0
  store i1 %eqtmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define { ptr, i64, i64 } @HashMap__new__val_bool() {
bb0:
  %_0 = alloca { ptr, i64, i64 }, align 8
  %_1 = alloca ptr, align 8
  store ptr null, ptr %_1, align 8
  %load__1 = load ptr, ptr %_1, align 8
  %f_gep_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %_0, i32 0, i32 0
  store ptr %load__1, ptr %f_gep_0, align 8
  %f_gep_1 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %_0, i32 0, i32 1
  store i64 0, ptr %f_gep_1, align 8
  %f_gep_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %_0, i32 0, i32 2
  store i64 0, ptr %f_gep_2, align 8
  %ret_val = load { ptr, i64, i64 }, ptr %_0, align 8
  ret { ptr, i64, i64 } %ret_val
}

define { i64, i32 } @Instant__elapsed({ i64, i64 } %0) {
bb0:
  %_0 = alloca { i64, i32 }, align 8
  %self = alloca { i64, i64 }, align 8
  %now = alloca { i64, i64 }, align 8
  %total_s = alloca i64, align 8
  %_4 = alloca i64, align 8
  %_5 = alloca i64, align 8
  %total_ns = alloca i64, align 8
  %_7 = alloca i64, align 8
  %_8 = alloca i64, align 8
  %_10 = alloca i1, align 1
  %_11 = alloca i64, align 8
  %_12 = alloca i32, align 4
  store { i64, i64 } %0, ptr %self, align 8
  %calltmp = call { i64, i64 } @Instant__now()
  store { i64, i64 } %calltmp, ptr %now, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %struct_f_0 = getelementptr inbounds nuw { i64, i64 }, ptr %now, i32 0, i32 0
  %load__2.0 = load i64, ptr %struct_f_0, align 8
  store i64 %load__2.0, ptr %_4, align 8
  %struct_f_01 = getelementptr inbounds nuw { i64, i64 }, ptr %self, i32 0, i32 0
  %load__1.0 = load i64, ptr %struct_f_01, align 8
  store i64 %load__1.0, ptr %_5, align 8
  %load__4 = load i64, ptr %_4, align 8
  %load__5 = load i64, ptr %_5, align 8
  %subtmp = sub i64 %load__4, %load__5
  store i64 %subtmp, ptr %total_s, align 8
  %struct_f_1 = getelementptr inbounds nuw { i64, i64 }, ptr %now, i32 0, i32 1
  %load__2.1 = load i64, ptr %struct_f_1, align 8
  store i64 %load__2.1, ptr %_7, align 8
  %struct_f_12 = getelementptr inbounds nuw { i64, i64 }, ptr %self, i32 0, i32 1
  %load__1.1 = load i64, ptr %struct_f_12, align 8
  store i64 %load__1.1, ptr %_8, align 8
  %load__7 = load i64, ptr %_7, align 8
  %load__8 = load i64, ptr %_8, align 8
  %subtmp3 = sub i64 %load__7, %load__8
  store i64 %subtmp3, ptr %total_ns, align 8
  %load__6 = load i64, ptr %total_ns, align 8
  %lttmp = icmp slt i64 %load__6, 0
  store i1 %lttmp, ptr %_10, align 1
  %load__10 = load i1, ptr %_10, align 1
  switch i1 %load__10, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  %load__3 = load i64, ptr %total_s, align 8
  %subtmp4 = sub i64 %load__3, 1
  store i64 %subtmp4, ptr %total_s, align 8
  %load__65 = load i64, ptr %total_ns, align 8
  %addtmp = add i64 %load__65, 1000000000
  store i64 %addtmp, ptr %total_ns, align 8
  br label %bb4

bb3:                                              ; preds = %bb1
  br label %bb4

bb4:                                              ; preds = %bb3, %bb2
  %load__36 = load i64, ptr %total_s, align 8
  store i64 %load__36, ptr %_11, align 8
  %load__67 = load i64, ptr %total_ns, align 8
  %casttmp = trunc i64 %load__67 to i32
  store i32 %casttmp, ptr %_12, align 4
  %load__11 = load i64, ptr %_11, align 8
  %f_gep_0 = getelementptr inbounds nuw { i64, i32 }, ptr %_0, i32 0, i32 0
  store i64 %load__11, ptr %f_gep_0, align 8
  %load__12 = load i32, ptr %_12, align 4
  %f_gep_1 = getelementptr inbounds nuw { i64, i32 }, ptr %_0, i32 0, i32 1
  store i32 %load__12, ptr %f_gep_1, align 4
  %ret_val = load { i64, i32 }, ptr %_0, align 8
  ret { i64, i32 } %ret_val
}

define { i64, i64 } @Instant__now() {
bb0:
  %_0 = alloca { i64, i64 }, align 8
  %raw = alloca ptr, align 8
  %_2 = alloca i32, align 4
  %p = alloca ptr, align 8
  %s = alloca i64, align 8
  %_5 = alloca i32, align 4
  %ns = alloca i64, align 8
  %_7 = alloca i32, align 4
  %calltmp = call ptr @malloc(i64 16)
  store ptr %calltmp, ptr %raw, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__1 = load ptr, ptr %raw, align 8
  %calltmp1 = call i32 @clock_gettime(i32 1, ptr %load__1)
  store i32 %calltmp1, ptr %_2, align 4
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__12 = load ptr, ptr %raw, align 8
  store ptr %load__12, ptr %p, align 8
  store i32 0, ptr %_5, align 4
  %idx_load = load i32, ptr %_5, align 4
  %idx_ext = sext i32 %idx_load to i64
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i64, ptr %raw_ptr_load, i64 %idx_ext
  %"load__3[_5]" = load i64, ptr %ptr_idx, align 8
  store i64 %"load__3[_5]", ptr %s, align 8
  store i32 1, ptr %_7, align 4
  %idx_load3 = load i32, ptr %_7, align 4
  %idx_ext4 = sext i32 %idx_load3 to i64
  %raw_ptr_load5 = load ptr, ptr %p, align 8
  %ptr_idx6 = getelementptr i64, ptr %raw_ptr_load5, i64 %idx_ext4
  %"load__3[_7]" = load i64, ptr %ptr_idx6, align 8
  store i64 %"load__3[_7]", ptr %ns, align 8
  %load__17 = load ptr, ptr %raw, align 8
  call void @free(ptr %load__17)
  br label %bb3

bb3:                                              ; preds = %bb2
  %load__4 = load i64, ptr %s, align 8
  %f_gep_0 = getelementptr inbounds nuw { i64, i64 }, ptr %_0, i32 0, i32 0
  store i64 %load__4, ptr %f_gep_0, align 8
  %load__6 = load i64, ptr %ns, align 8
  %f_gep_1 = getelementptr inbounds nuw { i64, i64 }, ptr %_0, i32 0, i32 1
  store i64 %load__6, ptr %f_gep_1, align 8
  %ret_val = load { i64, i64 }, ptr %_0, align 8
  ret { i64, i64 } %ret_val
}

define ptr @JoinHandle__join({ i64 } %0) {
bb0:
  %_0 = alloca ptr, align 8
  %self = alloca { i64 }, align 8
  %ret_buf = alloca ptr, align 8
  %_3 = alloca i32, align 4
  %_4 = alloca i64, align 8
  %p = alloca ptr, align 8
  %val = alloca ptr, align 8
  %_7 = alloca i32, align 4
  store { i64 } %0, ptr %self, align 8
  %calltmp = call ptr @malloc(i64 8)
  store ptr %calltmp, ptr %ret_buf, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %struct_f_0 = getelementptr inbounds nuw { i64 }, ptr %self, i32 0, i32 0
  %load__1.0 = load i64, ptr %struct_f_0, align 8
  store i64 %load__1.0, ptr %_4, align 8
  %load__4 = load i64, ptr %_4, align 8
  %load__2 = load ptr, ptr %ret_buf, align 8
  %calltmp1 = call i32 @pthread_join(i64 %load__4, ptr %load__2)
  store i32 %calltmp1, ptr %_3, align 4
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__22 = load ptr, ptr %ret_buf, align 8
  store ptr %load__22, ptr %p, align 8
  store i32 0, ptr %_7, align 4
  %idx_load = load i32, ptr %_7, align 4
  %idx_ext = sext i32 %idx_load to i64
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr ptr, ptr %raw_ptr_load, i64 %idx_ext
  %"load__5[_7]" = load ptr, ptr %ptr_idx, align 8
  store ptr %"load__5[_7]", ptr %val, align 8
  %load__23 = load ptr, ptr %ret_buf, align 8
  call void @free(ptr %load__23)
  br label %bb3

bb3:                                              ; preds = %bb2
  %load__6 = load ptr, ptr %val, align 8
  store ptr %load__6, ptr %_0, align 8
  %ret_val = load ptr, ptr %_0, align 8
  ret ptr %ret_val
}

define void @Process__exit(i32 %0) {
bb0:
  %code = alloca i32, align 4
  store i32 %0, ptr %code, align 4
  %load__1 = load i32, ptr %code, align 4
  call void @exit(i32 %load__1)
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define i32 @Process__id() {
bb0:
  %_0 = alloca i32, align 4
  %calltmp = call i32 @getpid()
  store i32 %calltmp, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

define i32 @Process__run_command(ptr %0) {
bb0:
  %_0 = alloca i32, align 4
  %cmd = alloca ptr, align 8
  store ptr %0, ptr %cmd, align 8
  %load__1 = load ptr, ptr %cmd, align 8
  %calltmp = call i32 @system(ptr %load__1)
  store i32 %calltmp, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

define i1 @Stderr__write_line({} %0, ptr %1) {
bb0:
  %_0 = alloca i1, align 1
  %self = alloca {}, align 8
  %s = alloca ptr, align 8
  %ok = alloca i1, align 1
  %nl = alloca i64, align 8
  %_5 = alloca ptr, align 8
  %_6 = alloca i1, align 1
  store {} %0, ptr %self, align 1
  store ptr %1, ptr %s, align 8
  %load__1 = load {}, ptr %self, align 1
  %load__2 = load ptr, ptr %s, align 8
  %calltmp = call i1 @Stderr__write_str({} %load__1, ptr %load__2)
  store i1 %calltmp, ptr %ok, align 1
  br label %bb1

bb1:                                              ; preds = %bb0
  store ptr @str_lit.3, ptr %_5, align 8
  %load__5 = load ptr, ptr %_5, align 8
  %calltmp1 = call i64 @write(i32 2, ptr %load__5, i64 1)
  store i64 %calltmp1, ptr %nl, align 8
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__4 = load i64, ptr %nl, align 8
  %getmp = icmp sge i64 %load__4, 0
  store i1 %getmp, ptr %_6, align 1
  %load__3 = load i1, ptr %ok, align 1
  %load__6 = load i1, ptr %_6, align 1
  %andtmp = and i1 %load__3, %load__6
  store i1 %andtmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define i1 @Stderr__write_str({} %0, ptr %1) {
bb0:
  %_0 = alloca i1, align 1
  %self = alloca {}, align 8
  %s = alloca ptr, align 8
  %p = alloca ptr, align 8
  %len = alloca i64, align 8
  %_6 = alloca i1, align 1
  %_7 = alloca i8, align 1
  %res = alloca i64, align 8
  %_9 = alloca ptr, align 8
  store {} %0, ptr %self, align 1
  store ptr %1, ptr %s, align 8
  %load__2 = load ptr, ptr %s, align 8
  store ptr %load__2, ptr %p, align 8
  store i64 0, ptr %len, align 8
  br label %bb1

bb1:                                              ; preds = %bb2, %bb0
  %idx_load = load i64, ptr %len, align 8
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__3[_4]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__3[_4]", ptr %_7, align 1
  %load__7 = load i8, ptr %_7, align 1
  %netmp = icmp ne i8 %load__7, 0
  store i1 %netmp, ptr %_6, align 1
  %load__6 = load i1, ptr %_6, align 1
  switch i1 %load__6, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  %load__4 = load i64, ptr %len, align 8
  %addtmp = add i64 %load__4, 1
  store i64 %addtmp, ptr %len, align 8
  br label %bb1

bb3:                                              ; preds = %bb1
  %load__3 = load ptr, ptr %p, align 8
  store ptr %load__3, ptr %_9, align 8
  %load__9 = load ptr, ptr %_9, align 8
  %load__41 = load i64, ptr %len, align 8
  %calltmp = call i64 @write(i32 2, ptr %load__9, i64 %load__41)
  store i64 %calltmp, ptr %res, align 8
  br label %bb4

bb4:                                              ; preds = %bb3
  %load__8 = load i64, ptr %res, align 8
  %getmp = icmp sge i64 %load__8, 0
  store i1 %getmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define { i32, i8 } @Stdin__read_byte({} %0) {
bb0:
  %_0 = alloca { i32, i8 }, align 8
  %self = alloca {}, align 8
  %raw = alloca ptr, align 8
  %res = alloca i64, align 8
  %_4 = alloca i1, align 1
  %p = alloca ptr, align 8
  %b = alloca i8, align 1
  %_8 = alloca i32, align 4
  store {} %0, ptr %self, align 1
  %calltmp = call ptr @malloc(i64 1)
  store ptr %calltmp, ptr %raw, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__2 = load ptr, ptr %raw, align 8
  %calltmp1 = call i64 @read(i32 0, ptr %load__2, i64 1)
  store i64 %calltmp1, ptr %res, align 8
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__3 = load i64, ptr %res, align 8
  %letmp = icmp sle i64 %load__3, 0
  store i1 %letmp, ptr %_4, align 1
  %load__4 = load i1, ptr %_4, align 1
  switch i1 %load__4, label %bb4 [
    i1 true, label %bb3
  ]

bb3:                                              ; preds = %bb2
  %load__22 = load ptr, ptr %raw, align 8
  call void @free(ptr %load__22)
  br label %bb6

bb4:                                              ; preds = %bb2
  %load__23 = load ptr, ptr %raw, align 8
  store ptr %load__23, ptr %p, align 8
  store i32 0, ptr %_8, align 4
  %idx_load = load i32, ptr %_8, align 4
  %idx_ext = sext i32 %idx_load to i64
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_ext
  %"load__6[_8]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__6[_8]", ptr %b, align 1
  %load__24 = load ptr, ptr %raw, align 8
  call void @free(ptr %load__24)
  br label %bb7

bb5:                                              ; preds = %bb7, %bb6
  %ret_val = load { i32, i8 }, ptr %_0, align 4
  ret { i32, i8 } %ret_val

bb6:                                              ; preds = %bb3
  %f_gep_0 = getelementptr inbounds nuw { i32, i8 }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_0, align 4
  %f_gep_1 = getelementptr inbounds nuw { i32, i8 }, ptr %_0, i32 0, i32 1
  store i8 0, ptr %f_gep_1, align 1
  br label %bb5

bb7:                                              ; preds = %bb4
  %f_gep_05 = getelementptr inbounds nuw { i32, i8 }, ptr %_0, i32 0, i32 0
  store i32 1, ptr %f_gep_05, align 4
  %load__7 = load i8, ptr %b, align 1
  %f_gep_16 = getelementptr inbounds nuw { i32, i8 }, ptr %_0, i32 0, i32 1
  store i8 %load__7, ptr %f_gep_16, align 1
  br label %bb5
}

define i1 @Stdout__write_line({} %0, ptr %1) {
bb0:
  %_0 = alloca i1, align 1
  %self = alloca {}, align 8
  %s = alloca ptr, align 8
  %ok = alloca i1, align 1
  %nl = alloca i64, align 8
  %_5 = alloca ptr, align 8
  %_6 = alloca i1, align 1
  store {} %0, ptr %self, align 1
  store ptr %1, ptr %s, align 8
  %load__1 = load {}, ptr %self, align 1
  %load__2 = load ptr, ptr %s, align 8
  %calltmp = call i1 @Stdout__write_str({} %load__1, ptr %load__2)
  store i1 %calltmp, ptr %ok, align 1
  br label %bb1

bb1:                                              ; preds = %bb0
  store ptr @str_lit.4, ptr %_5, align 8
  %load__5 = load ptr, ptr %_5, align 8
  %calltmp1 = call i64 @write(i32 1, ptr %load__5, i64 1)
  store i64 %calltmp1, ptr %nl, align 8
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__4 = load i64, ptr %nl, align 8
  %getmp = icmp sge i64 %load__4, 0
  store i1 %getmp, ptr %_6, align 1
  %load__3 = load i1, ptr %ok, align 1
  %load__6 = load i1, ptr %_6, align 1
  %andtmp = and i1 %load__3, %load__6
  store i1 %andtmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define i1 @Stdout__write_str({} %0, ptr %1) {
bb0:
  %_0 = alloca i1, align 1
  %self = alloca {}, align 8
  %s = alloca ptr, align 8
  %p = alloca ptr, align 8
  %len = alloca i64, align 8
  %_6 = alloca i1, align 1
  %_7 = alloca i8, align 1
  %res = alloca i64, align 8
  %_9 = alloca ptr, align 8
  store {} %0, ptr %self, align 1
  store ptr %1, ptr %s, align 8
  %load__2 = load ptr, ptr %s, align 8
  store ptr %load__2, ptr %p, align 8
  store i64 0, ptr %len, align 8
  br label %bb1

bb1:                                              ; preds = %bb2, %bb0
  %idx_load = load i64, ptr %len, align 8
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__3[_4]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__3[_4]", ptr %_7, align 1
  %load__7 = load i8, ptr %_7, align 1
  %netmp = icmp ne i8 %load__7, 0
  store i1 %netmp, ptr %_6, align 1
  %load__6 = load i1, ptr %_6, align 1
  switch i1 %load__6, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  %load__4 = load i64, ptr %len, align 8
  %addtmp = add i64 %load__4, 1
  store i64 %addtmp, ptr %len, align 8
  br label %bb1

bb3:                                              ; preds = %bb1
  %load__3 = load ptr, ptr %p, align 8
  store ptr %load__3, ptr %_9, align 8
  %load__9 = load ptr, ptr %_9, align 8
  %load__41 = load i64, ptr %len, align 8
  %calltmp = call i64 @write(i32 1, ptr %load__9, i64 %load__41)
  store i64 %calltmp, ptr %res, align 8
  br label %bb4

bb4:                                              ; preds = %bb3
  %load__8 = load i64, ptr %res, align 8
  %getmp = icmp sge i64 %load__8, 0
  store i1 %getmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define ptr @String__as_ptr({ { ptr, i64, i64 } } %0) {
bb0:
  %_0 = alloca ptr, align 8
  %self = alloca { { ptr, i64, i64 } }, align 8
  %_2 = alloca i1, align 1
  %_3 = alloca i64, align 8
  %_4 = alloca ptr, align 8
  %_5 = alloca ptr, align 8
  store { { ptr, i64, i64 } } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %self, i32 0, i32 0
  %struct_f_01 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %struct_f_0, i32 0, i32 0
  %load__1.0.0 = load ptr, ptr %struct_f_01, align 8
  store ptr %load__1.0.0, ptr %_4, align 8
  %load__4 = load ptr, ptr %_4, align 8
  %ptr2int = ptrtoint ptr %load__4 to i64
  store i64 %ptr2int, ptr %_3, align 8
  %load__3 = load i64, ptr %_3, align 8
  %eqtmp = icmp eq i64 %load__3, 0
  store i1 %eqtmp, ptr %_2, align 1
  %load__2 = load i1, ptr %_2, align 1
  switch i1 %load__2, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  store ptr @str_lit.5, ptr %_0, align 8
  br label %bb3

bb2:                                              ; preds = %bb0
  %struct_f_02 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %self, i32 0, i32 0
  %struct_f_03 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %struct_f_02, i32 0, i32 0
  %load__1.0.04 = load ptr, ptr %struct_f_03, align 8
  store ptr %load__1.0.04, ptr %_5, align 8
  %load__5 = load ptr, ptr %_5, align 8
  store ptr %load__5, ptr %_0, align 8
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %ret_val = load ptr, ptr %_0, align 8
  ret ptr %ret_val
}

define void @String__drop(ptr %0) {
bb0:
  %struct_f_0 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %0, i32 0, i32 0
  %struct_f_01 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %0, i32 0, i32 0
  call void @Vec__drop__u8(ptr %struct_f_01)
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define { { ptr, i64, i64 } } @String__from_raw(ptr %0, i64 %1) {
bb0:
  %_0 = alloca { { ptr, i64, i64 } }, align 8
  %ptr = alloca ptr, align 8
  %length = alloca i64, align 8
  %s = alloca { { ptr, i64, i64 } }, align 8
  %i = alloca i64, align 8
  %_6 = alloca i1, align 1
  %_8 = alloca i8, align 1
  store ptr %0, ptr %ptr, align 8
  store i64 %1, ptr %length, align 8
  %calltmp = call { { ptr, i64, i64 } } @String__new()
  store { { ptr, i64, i64 } } %calltmp, ptr %s, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  store i64 0, ptr %i, align 8
  br label %bb2

bb2:                                              ; preds = %bb5, %bb1
  %load__4 = load i64, ptr %i, align 8
  %load__2 = load i64, ptr %length, align 8
  %lttmp = icmp slt i64 %load__4, %load__2
  store i1 %lttmp, ptr %_6, align 1
  %load__6 = load i1, ptr %_6, align 1
  switch i1 %load__6, label %bb4 [
    i1 true, label %bb3
  ]

bb3:                                              ; preds = %bb2
  %idx_load = load i64, ptr %i, align 8
  %raw_ptr_load = load ptr, ptr %ptr, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__1[_4]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__1[_4]", ptr %_8, align 1
  %struct_f_0 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %s, i32 0, i32 0
  %struct_f_01 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %s, i32 0, i32 0
  %load__8 = load i8, ptr %_8, align 1
  call void @Vec__push__u8(ptr %struct_f_01, i8 %load__8)
  br label %bb5

bb4:                                              ; preds = %bb2
  %load__3 = load { { ptr, i64, i64 } }, ptr %s, align 8
  store { { ptr, i64, i64 } } %load__3, ptr %_0, align 8
  %ret_val = load { { ptr, i64, i64 } }, ptr %_0, align 8
  ret { { ptr, i64, i64 } } %ret_val

bb5:                                              ; preds = %bb3
  %load__42 = load i64, ptr %i, align 8
  %addtmp = add i64 %load__42, 1
  store i64 %addtmp, ptr %i, align 8
  br label %bb2
}

define { { ptr, i64, i64 } } @String__from_str(ptr %0) {
bb0:
  %_0 = alloca { { ptr, i64, i64 } }, align 8
  %s = alloca ptr, align 8
  %str_obj = alloca { { ptr, i64, i64 } }, align 8
  store ptr %0, ptr %s, align 8
  %calltmp = call { { ptr, i64, i64 } } @String__new()
  store { { ptr, i64, i64 } } %calltmp, ptr %str_obj, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__1 = load ptr, ptr %s, align 8
  call void @String__push_str(ptr %str_obj, ptr %load__1)
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__2 = load { { ptr, i64, i64 } }, ptr %str_obj, align 8
  store { { ptr, i64, i64 } } %load__2, ptr %_0, align 8
  %ret_val = load { { ptr, i64, i64 } }, ptr %_0, align 8
  ret { { ptr, i64, i64 } } %ret_val
}

define { i32, i8 } @String__get_byte({ { ptr, i64, i64 } } %0, i64 %1) {
bb0:
  %_0 = alloca { i32, i8 }, align 8
  %self = alloca { { ptr, i64, i64 } }, align 8
  %idx = alloca i64, align 8
  %_3 = alloca { ptr, i64, i64 }, align 8
  store { { ptr, i64, i64 } } %0, ptr %self, align 8
  store i64 %1, ptr %idx, align 8
  %struct_f_0 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %self, i32 0, i32 0
  %load__1.0 = load { ptr, i64, i64 }, ptr %struct_f_0, align 8
  store { ptr, i64, i64 } %load__1.0, ptr %_3, align 8
  %load__3 = load { ptr, i64, i64 }, ptr %_3, align 8
  %load__2 = load i64, ptr %idx, align 8
  %calltmp = call { i32, i8 } @Vec__get__u8({ ptr, i64, i64 } %load__3, i64 %load__2)
  store { i32, i8 } %calltmp, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load { i32, i8 }, ptr %_0, align 4
  ret { i32, i8 } %ret_val
}

define i1 @String__is_empty({ { ptr, i64, i64 } } %0) {
bb0:
  %_0 = alloca i1, align 1
  %self = alloca { { ptr, i64, i64 } }, align 8
  %_2 = alloca i64, align 8
  store { { ptr, i64, i64 } } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %self, i32 0, i32 0
  %struct_f_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %struct_f_0, i32 0, i32 2
  %load__1.0.2 = load i64, ptr %struct_f_2, align 8
  store i64 %load__1.0.2, ptr %_2, align 8
  %load__2 = load i64, ptr %_2, align 8
  %eqtmp = icmp eq i64 %load__2, 0
  store i1 %eqtmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define i64 @String__len({ { ptr, i64, i64 } } %0) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { { ptr, i64, i64 } }, align 8
  store { { ptr, i64, i64 } } %0, ptr %self, align 8
  %struct_f_0 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %self, i32 0, i32 0
  %struct_f_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %struct_f_0, i32 0, i32 2
  %load__1.0.2 = load i64, ptr %struct_f_2, align 8
  store i64 %load__1.0.2, ptr %_0, align 8
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define { { ptr, i64, i64 } } @String__new() {
bb0:
  %_0 = alloca { { ptr, i64, i64 } }, align 8
  %_1 = alloca { ptr, i64, i64 }, align 8
  %calltmp = call { ptr, i64, i64 } @Vec__new__u8()
  store { ptr, i64, i64 } %calltmp, ptr %_1, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__1 = load { ptr, i64, i64 }, ptr %_1, align 8
  %f_gep_0 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %_0, i32 0, i32 0
  store { ptr, i64, i64 } %load__1, ptr %f_gep_0, align 8
  %ret_val = load { { ptr, i64, i64 } }, ptr %_0, align 8
  ret { { ptr, i64, i64 } } %ret_val
}

define void @String__push_byte(ptr %0, i8 %1) {
bb0:
  %byte = alloca i8, align 1
  store i8 %1, ptr %byte, align 1
  %struct_f_0 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %0, i32 0, i32 0
  %struct_f_01 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %0, i32 0, i32 0
  %load__2 = load i8, ptr %byte, align 1
  call void @Vec__push__u8(ptr %struct_f_01, i8 %load__2)
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define void @String__push_char(ptr %0, i32 %1) {
bb0:
  %ch = alloca i32, align 4
  %_3 = alloca i8, align 1
  store i32 %1, ptr %ch, align 4
  %load__2 = load i32, ptr %ch, align 4
  %casttmp = trunc i32 %load__2 to i8
  store i8 %casttmp, ptr %_3, align 1
  %struct_f_0 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %0, i32 0, i32 0
  %struct_f_01 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %0, i32 0, i32 0
  %load__3 = load i8, ptr %_3, align 1
  call void @Vec__push__u8(ptr %struct_f_01, i8 %load__3)
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define void @String__push_str(ptr %0, ptr %1) {
bb0:
  %s = alloca ptr, align 8
  %_4 = alloca i1, align 1
  %_5 = alloca i64, align 8
  %p = alloca ptr, align 8
  %i = alloca i64, align 8
  %_8 = alloca i1, align 1
  %_9 = alloca i8, align 1
  %_11 = alloca i8, align 1
  store ptr %1, ptr %s, align 8
  %load__2 = load ptr, ptr %s, align 8
  %ptr2int = ptrtoint ptr %load__2 to i64
  store i64 %ptr2int, ptr %_5, align 8
  %load__5 = load i64, ptr %_5, align 8
  %eqtmp = icmp eq i64 %load__5, 0
  store i1 %eqtmp, ptr %_4, align 1
  %load__4 = load i1, ptr %_4, align 1
  switch i1 %load__4, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  ret void

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb2
  %load__21 = load ptr, ptr %s, align 8
  store ptr %load__21, ptr %p, align 8
  store i64 0, ptr %i, align 8
  br label %bb4

bb4:                                              ; preds = %bb7, %bb3
  %idx_load = load i64, ptr %i, align 8
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__6[_7]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__6[_7]", ptr %_9, align 1
  %load__9 = load i8, ptr %_9, align 1
  %netmp = icmp ne i8 %load__9, 0
  store i1 %netmp, ptr %_8, align 1
  %load__8 = load i1, ptr %_8, align 1
  switch i1 %load__8, label %bb6 [
    i1 true, label %bb5
  ]

bb5:                                              ; preds = %bb4
  %idx_load2 = load i64, ptr %i, align 8
  %raw_ptr_load3 = load ptr, ptr %p, align 8
  %ptr_idx4 = getelementptr i8, ptr %raw_ptr_load3, i64 %idx_load2
  %"load__6[_7]5" = load i8, ptr %ptr_idx4, align 1
  store i8 %"load__6[_7]5", ptr %_11, align 1
  %struct_f_0 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %0, i32 0, i32 0
  %struct_f_06 = getelementptr inbounds nuw { { ptr, i64, i64 } }, ptr %0, i32 0, i32 0
  %load__11 = load i8, ptr %_11, align 1
  call void @Vec__push__u8(ptr %struct_f_06, i8 %load__11)
  br label %bb7

bb6:                                              ; preds = %bb4
  ret void

bb7:                                              ; preds = %bb5
  %load__7 = load i64, ptr %i, align 8
  %addtmp = add i64 %load__7, 1
  store i64 %addtmp, ptr %i, align 8
  br label %bb4
}

define { ptr, i1 } @Task__new__val(ptr %0) {
bb0:
  %_0 = alloca { ptr, i1 }, align 8
  %f = alloca ptr, align 8
  store ptr %0, ptr %f, align 8
  %load__1 = load ptr, ptr %f, align 8
  %f_gep_0 = getelementptr inbounds nuw { ptr, i1 }, ptr %_0, i32 0, i32 0
  store ptr %load__1, ptr %f_gep_0, align 8
  %f_gep_1 = getelementptr inbounds nuw { ptr, i1 }, ptr %_0, i32 0, i32 1
  store i1 false, ptr %f_gep_1, align 1
  %ret_val = load { ptr, i1 }, ptr %_0, align 8
  ret { ptr, i1 } %ret_val
}

define { i32, i32 } @Task__poll__val(ptr %0) {
bb0:
  %_0 = alloca { i32, i32 }, align 8
  %_2 = alloca i1, align 1
  %res = alloca i32, align 4
  %_4 = alloca ptr, align 8
  %struct_f_1 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i1, ptr %struct_f_1, align 1
  store i1 %load__1.1, ptr %_2, align 1
  %load__2 = load i1, ptr %_2, align 1
  switch i1 %load__2, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %f_gep_0 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_0, align 4
  %f_gep_1 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 1
  store i32 0, ptr %f_gep_1, align 4
  br label %bb3

bb2:                                              ; preds = %bb0
  %struct_f_0 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_4, align 8
  %load__4 = load ptr, ptr %_4, align 8
  %indirect_call = call i32 %load__4()
  store i32 %indirect_call, ptr %res, align 4
  br label %bb4

bb3:                                              ; preds = %bb4, %bb1
  %ret_val = load { i32, i32 }, ptr %_0, align 4
  ret { i32, i32 } %ret_val

bb4:                                              ; preds = %bb2
  %struct_f_11 = getelementptr inbounds nuw { ptr, i1 }, ptr %0, i32 0, i32 1
  store i1 true, ptr %struct_f_11, align 1
  %f_gep_02 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 0
  store i32 1, ptr %f_gep_02, align 4
  %load__3 = load i32, ptr %res, align 4
  %f_gep_13 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 1
  store i32 %load__3, ptr %f_gep_13, align 4
  br label %bb3
}

define void @TcpStream__close(ptr %0) {
bb0:
  %_2 = alloca i1, align 1
  %_3 = alloca i32, align 4
  %_4 = alloca i32, align 4
  %struct_f_1 = getelementptr inbounds nuw { i32, i1 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i1, ptr %struct_f_1, align 1
  store i1 %load__1.1, ptr %_2, align 1
  %load__2 = load i1, ptr %_2, align 1
  switch i1 %load__2, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %struct_f_0 = getelementptr inbounds nuw { i32, i1 }, ptr %0, i32 0, i32 0
  %load__1.0 = load i32, ptr %struct_f_0, align 4
  store i32 %load__1.0, ptr %_4, align 4
  %load__4 = load i32, ptr %_4, align 4
  %calltmp = call i32 @close(i32 %load__4)
  store i32 %calltmp, ptr %_3, align 4
  br label %bb4

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb4, %bb2
  ret void

bb4:                                              ; preds = %bb1
  %struct_f_11 = getelementptr inbounds nuw { i32, i1 }, ptr %0, i32 0, i32 1
  store i1 false, ptr %struct_f_11, align 1
  br label %bb3
}

define { i32, { i32, i1 } } @TcpStream__connect(ptr %0, i16 %1) {
bb0:
  %_0 = alloca { i32, { i32, i1 } }, align 8
  %host_ip = alloca ptr, align 8
  %port = alloca i16, align 2
  %sock = alloca i32, align 4
  %_5 = alloca i1, align 1
  %raw = alloca ptr, align 8
  %p = alloca ptr, align 8
  %i = alloca i64, align 8
  %_10 = alloca i1, align 1
  %p16 = alloca ptr, align 8
  %_12 = alloca i32, align 4
  %p_be = alloca i16, align 2
  %_14 = alloca i16, align 2
  %_15 = alloca i16, align 2
  %_16 = alloca i16, align 2
  %_17 = alloca i32, align 4
  %res = alloca i32, align 4
  %_20 = alloca i1, align 1
  %_21 = alloca i32, align 4
  %_22 = alloca { i32, i1 }, align 8
  store ptr %0, ptr %host_ip, align 8
  store i16 %1, ptr %port, align 2
  %calltmp = call i32 @socket(i32 2, i32 1, i32 0)
  store i32 %calltmp, ptr %sock, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__3 = load i32, ptr %sock, align 4
  %lttmp = icmp slt i32 %load__3, 0
  store i1 %lttmp, ptr %_5, align 1
  %load__5 = load i1, ptr %_5, align 1
  switch i1 %load__5, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  %f_gep_0 = getelementptr inbounds nuw { i32, { i32, i1 } }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_0, align 4
  %f_gep_1 = getelementptr inbounds nuw { i32, { i32, i1 } }, ptr %_0, i32 0, i32 1
  store { i32, i1 } zeroinitializer, ptr %f_gep_1, align 4
  %ret_val = load { i32, { i32, i1 } }, ptr %_0, align 4
  ret { i32, { i32, i1 } } %ret_val

bb3:                                              ; preds = %bb1
  br label %bb4

bb4:                                              ; preds = %bb3
  %calltmp1 = call ptr @malloc(i64 16)
  store ptr %calltmp1, ptr %raw, align 8
  br label %bb5

bb5:                                              ; preds = %bb4
  %load__6 = load ptr, ptr %raw, align 8
  store ptr %load__6, ptr %p, align 8
  store i64 0, ptr %i, align 8
  br label %bb6

bb6:                                              ; preds = %bb7, %bb5
  %load__8 = load i64, ptr %i, align 8
  %lttmp2 = icmp slt i64 %load__8, 16
  store i1 %lttmp2, ptr %_10, align 1
  %load__10 = load i1, ptr %_10, align 1
  switch i1 %load__10, label %bb8 [
    i1 true, label %bb7
  ]

bb7:                                              ; preds = %bb6
  %idx_load = load i64, ptr %i, align 8
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  store i8 0, ptr %ptr_idx, align 1
  %load__83 = load i64, ptr %i, align 8
  %addtmp = add i64 %load__83, 1
  store i64 %addtmp, ptr %i, align 8
  br label %bb6

bb8:                                              ; preds = %bb6
  %load__64 = load ptr, ptr %raw, align 8
  store ptr %load__64, ptr %p16, align 8
  store i32 0, ptr %_12, align 4
  %idx_load5 = load i32, ptr %_12, align 4
  %idx_ext = sext i32 %idx_load5 to i64
  %raw_ptr_load6 = load ptr, ptr %p16, align 8
  %ptr_idx7 = getelementptr i16, ptr %raw_ptr_load6, i64 %idx_ext
  store i16 2, ptr %ptr_idx7, align 2
  %load__2 = load i16, ptr %port, align 2
  %shrtmp = ashr i16 %load__2, 8
  store i16 %shrtmp, ptr %_15, align 2
  %load__28 = load i16, ptr %port, align 2
  %shltmp = shl i16 %load__28, 8
  store i16 %shltmp, ptr %_16, align 2
  %load__15 = load i16, ptr %_15, align 2
  %load__16 = load i16, ptr %_16, align 2
  %ortmp = or i16 %load__15, %load__16
  store i16 %ortmp, ptr %_14, align 2
  %load__14 = load i16, ptr %_14, align 2
  store i16 %load__14, ptr %p_be, align 2
  store i32 1, ptr %_17, align 4
  %load__13 = load i16, ptr %p_be, align 2
  %idx_load9 = load i32, ptr %_17, align 4
  %idx_ext10 = sext i32 %idx_load9 to i64
  %raw_ptr_load11 = load ptr, ptr %p16, align 8
  %ptr_idx12 = getelementptr i16, ptr %raw_ptr_load11, i64 %idx_ext10
  store i16 %load__13, ptr %ptr_idx12, align 2
  %load__313 = load i32, ptr %sock, align 4
  %load__614 = load ptr, ptr %raw, align 8
  %calltmp15 = call i32 @connect(i32 %load__313, ptr %load__614, i32 16)
  store i32 %calltmp15, ptr %res, align 4
  br label %bb9

bb9:                                              ; preds = %bb8
  %load__616 = load ptr, ptr %raw, align 8
  call void @free(ptr %load__616)
  br label %bb10

bb10:                                             ; preds = %bb9
  %load__18 = load i32, ptr %res, align 4
  %lttmp17 = icmp slt i32 %load__18, 0
  store i1 %lttmp17, ptr %_20, align 1
  %load__20 = load i1, ptr %_20, align 1
  switch i1 %load__20, label %bb12 [
    i1 true, label %bb11
  ]

bb11:                                             ; preds = %bb10
  %load__318 = load i32, ptr %sock, align 4
  %calltmp19 = call i32 @close(i32 %load__318)
  store i32 %calltmp19, ptr %_21, align 4
  br label %bb14

bb12:                                             ; preds = %bb10
  %load__320 = load i32, ptr %sock, align 4
  %f_gep_021 = getelementptr inbounds nuw { i32, i1 }, ptr %_22, i32 0, i32 0
  store i32 %load__320, ptr %f_gep_021, align 4
  %f_gep_122 = getelementptr inbounds nuw { i32, i1 }, ptr %_22, i32 0, i32 1
  store i1 true, ptr %f_gep_122, align 1
  %f_gep_023 = getelementptr inbounds nuw { i32, { i32, i1 } }, ptr %_0, i32 0, i32 0
  store i32 1, ptr %f_gep_023, align 4
  %load__22 = load { i32, i1 }, ptr %_22, align 4
  %f_gep_124 = getelementptr inbounds nuw { i32, { i32, i1 } }, ptr %_0, i32 0, i32 1
  store { i32, i1 } %load__22, ptr %f_gep_124, align 4
  br label %bb13

bb13:                                             ; preds = %bb14, %bb12
  %ret_val25 = load { i32, { i32, i1 } }, ptr %_0, align 4
  ret { i32, { i32, i1 } } %ret_val25

bb14:                                             ; preds = %bb11
  %f_gep_026 = getelementptr inbounds nuw { i32, { i32, i1 } }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_026, align 4
  %f_gep_127 = getelementptr inbounds nuw { i32, { i32, i1 } }, ptr %_0, i32 0, i32 1
  store { i32, i1 } zeroinitializer, ptr %f_gep_127, align 4
  br label %bb13
}

define void @TcpStream__drop(ptr %0) {
bb0:
  call void @TcpStream__close(ptr %0)
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define i1 @TcpStream__write_str(ptr %0, ptr %1) {
bb0:
  %_0 = alloca i1, align 1
  %s = alloca ptr, align 8
  %_4 = alloca i1, align 1
  %_5 = alloca i1, align 1
  %p = alloca ptr, align 8
  %len = alloca i64, align 8
  %_9 = alloca i1, align 1
  %_10 = alloca i8, align 1
  %sent = alloca i64, align 8
  %_12 = alloca i32, align 4
  %_13 = alloca ptr, align 8
  %_14 = alloca i64, align 8
  store ptr %1, ptr %s, align 8
  %struct_f_1 = getelementptr inbounds nuw { i32, i1 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i1, ptr %struct_f_1, align 1
  store i1 %load__1.1, ptr %_5, align 1
  %load__5 = load i1, ptr %_5, align 1
  %nottmp = xor i1 %load__5, true
  store i1 %nottmp, ptr %_4, align 1
  %load__4 = load i1, ptr %_4, align 1
  switch i1 %load__4, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  store i1 false, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb2
  %load__2 = load ptr, ptr %s, align 8
  store ptr %load__2, ptr %p, align 8
  store i64 0, ptr %len, align 8
  br label %bb4

bb4:                                              ; preds = %bb5, %bb3
  %idx_load = load i64, ptr %len, align 8
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__6[_7]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__6[_7]", ptr %_10, align 1
  %load__10 = load i8, ptr %_10, align 1
  %netmp = icmp ne i8 %load__10, 0
  store i1 %netmp, ptr %_9, align 1
  %load__9 = load i1, ptr %_9, align 1
  switch i1 %load__9, label %bb6 [
    i1 true, label %bb5
  ]

bb5:                                              ; preds = %bb4
  %load__7 = load i64, ptr %len, align 8
  %addtmp = add i64 %load__7, 1
  store i64 %addtmp, ptr %len, align 8
  br label %bb4

bb6:                                              ; preds = %bb4
  %struct_f_0 = getelementptr inbounds nuw { i32, i1 }, ptr %0, i32 0, i32 0
  %load__1.0 = load i32, ptr %struct_f_0, align 4
  store i32 %load__1.0, ptr %_12, align 4
  %load__6 = load ptr, ptr %p, align 8
  store ptr %load__6, ptr %_13, align 8
  %load__12 = load i32, ptr %_12, align 4
  %load__13 = load ptr, ptr %_13, align 8
  %load__71 = load i64, ptr %len, align 8
  %calltmp = call i64 @send(i32 %load__12, ptr %load__13, i64 %load__71, i32 0)
  store i64 %calltmp, ptr %sent, align 8
  br label %bb7

bb7:                                              ; preds = %bb6
  %load__72 = load i64, ptr %len, align 8
  store i64 %load__72, ptr %_14, align 8
  %load__11 = load i64, ptr %sent, align 8
  %load__14 = load i64, ptr %_14, align 8
  %eqtmp = icmp eq i64 %load__11, %load__14
  store i1 %eqtmp, ptr %_0, align 1
  %ret_val3 = load i1, ptr %_0, align 1
  ret i1 %ret_val3
}

define void @Vec__drop__u8(ptr %0) {
bb0:
  %_2 = alloca i1, align 1
  %_3 = alloca i64, align 8
  %_5 = alloca ptr, align 8
  %_6 = alloca ptr, align 8
  %struct_f_1 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i64, ptr %struct_f_1, align 8
  store i64 %load__1.1, ptr %_3, align 8
  %load__3 = load i64, ptr %_3, align 8
  %gttmp = icmp sgt i64 %load__3, 0
  store i1 %gttmp, ptr %_2, align 1
  %load__2 = load i1, ptr %_2, align 1
  switch i1 %load__2, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %struct_f_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_0, align 8
  store ptr %load__1.0, ptr %_6, align 8
  %load__6 = load ptr, ptr %_6, align 8
  store ptr %load__6, ptr %_5, align 8
  %load__5 = load ptr, ptr %_5, align 8
  call void @free(ptr %load__5)
  br label %bb4

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb4, %bb2
  ret void

bb4:                                              ; preds = %bb1
  %struct_f_11 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  store i64 0, ptr %struct_f_11, align 8
  %struct_f_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  store i64 0, ptr %struct_f_2, align 8
  br label %bb3
}

define { i32, i8 } @Vec__get__u8({ ptr, i64, i64 } %0, i64 %1) {
bb0:
  %_0 = alloca { i32, i8 }, align 8
  %self = alloca { ptr, i64, i64 }, align 8
  %idx = alloca i64, align 8
  %_3 = alloca i1, align 1
  %_4 = alloca i64, align 8
  %_5 = alloca i8, align 1
  store { ptr, i64, i64 } %0, ptr %self, align 8
  store i64 %1, ptr %idx, align 8
  %struct_f_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 2
  %load__1.2 = load i64, ptr %struct_f_2, align 8
  store i64 %load__1.2, ptr %_4, align 8
  %load__2 = load i64, ptr %idx, align 8
  %load__4 = load i64, ptr %_4, align 8
  %getmp = icmp sge i64 %load__2, %load__4
  store i1 %getmp, ptr %_3, align 1
  %load__3 = load i1, ptr %_3, align 1
  switch i1 %load__3, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %f_gep_0 = getelementptr inbounds nuw { i32, i8 }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_0, align 4
  %f_gep_1 = getelementptr inbounds nuw { i32, i8 }, ptr %_0, i32 0, i32 1
  store i8 0, ptr %f_gep_1, align 1
  br label %bb3

bb2:                                              ; preds = %bb0
  %struct_f_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 0
  %idx_load = load i64, ptr %idx, align 8
  %raw_ptr_load = load ptr, ptr %struct_f_0, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__1.0[_2]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__1.0[_2]", ptr %_5, align 1
  %f_gep_01 = getelementptr inbounds nuw { i32, i8 }, ptr %_0, i32 0, i32 0
  store i32 1, ptr %f_gep_01, align 4
  %load__5 = load i8, ptr %_5, align 1
  %f_gep_12 = getelementptr inbounds nuw { i32, i8 }, ptr %_0, i32 0, i32 1
  store i8 %load__5, ptr %f_gep_12, align 1
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %ret_val = load { i32, i8 }, ptr %_0, align 4
  ret { i32, i8 } %ret_val
}

define { i32, i32 } @Vec__get__val({ ptr, i64, i64 } %0, i64 %1) {
bb0:
  %_0 = alloca { i32, i32 }, align 8
  %self = alloca { ptr, i64, i64 }, align 8
  %idx = alloca i64, align 8
  %_3 = alloca i1, align 1
  %_4 = alloca i64, align 8
  %_5 = alloca i32, align 4
  store { ptr, i64, i64 } %0, ptr %self, align 8
  store i64 %1, ptr %idx, align 8
  %struct_f_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 2
  %load__1.2 = load i64, ptr %struct_f_2, align 8
  store i64 %load__1.2, ptr %_4, align 8
  %load__2 = load i64, ptr %idx, align 8
  %load__4 = load i64, ptr %_4, align 8
  %getmp = icmp sge i64 %load__2, %load__4
  store i1 %getmp, ptr %_3, align 1
  %load__3 = load i1, ptr %_3, align 1
  switch i1 %load__3, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %f_gep_0 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_0, align 4
  %f_gep_1 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 1
  store i32 0, ptr %f_gep_1, align 4
  br label %bb3

bb2:                                              ; preds = %bb0
  %struct_f_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 0
  %idx_load = load i64, ptr %idx, align 8
  %raw_ptr_load = load ptr, ptr %struct_f_0, align 8
  %ptr_idx = getelementptr i32, ptr %raw_ptr_load, i64 %idx_load
  %"load__1.0[_2]" = load i32, ptr %ptr_idx, align 4
  store i32 %"load__1.0[_2]", ptr %_5, align 4
  %f_gep_01 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 0
  store i32 1, ptr %f_gep_01, align 4
  %load__5 = load i32, ptr %_5, align 4
  %f_gep_12 = getelementptr inbounds nuw { i32, i32 }, ptr %_0, i32 0, i32 1
  store i32 %load__5, ptr %f_gep_12, align 4
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %ret_val = load { i32, i32 }, ptr %_0, align 4
  ret { i32, i32 } %ret_val
}

define i64 @Vec__len__val({ ptr, i64, i64 } %0) {
bb0:
  %_0 = alloca i64, align 8
  %self = alloca { ptr, i64, i64 }, align 8
  store { ptr, i64, i64 } %0, ptr %self, align 8
  %struct_f_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %self, i32 0, i32 2
  %load__1.2 = load i64, ptr %struct_f_2, align 8
  store i64 %load__1.2, ptr %_0, align 8
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

define { ptr, i64, i64 } @Vec__new__u8() {
bb0:
  %_0 = alloca { ptr, i64, i64 }, align 8
  %_1 = alloca ptr, align 8
  store ptr null, ptr %_1, align 8
  %load__1 = load ptr, ptr %_1, align 8
  %f_gep_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %_0, i32 0, i32 0
  store ptr %load__1, ptr %f_gep_0, align 8
  %f_gep_1 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %_0, i32 0, i32 1
  store i64 0, ptr %f_gep_1, align 8
  %f_gep_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %_0, i32 0, i32 2
  store i64 0, ptr %f_gep_2, align 8
  %ret_val = load { ptr, i64, i64 }, ptr %_0, align 8
  ret { ptr, i64, i64 } %ret_val
}

define { ptr, i64, i64 } @Vec__new__val() {
bb0:
  %_0 = alloca { ptr, i64, i64 }, align 8
  %_1 = alloca ptr, align 8
  store ptr null, ptr %_1, align 8
  %load__1 = load ptr, ptr %_1, align 8
  %f_gep_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %_0, i32 0, i32 0
  store ptr %load__1, ptr %f_gep_0, align 8
  %f_gep_1 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %_0, i32 0, i32 1
  store i64 0, ptr %f_gep_1, align 8
  %f_gep_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %_0, i32 0, i32 2
  store i64 0, ptr %f_gep_2, align 8
  %ret_val = load { ptr, i64, i64 }, ptr %_0, align 8
  ret { ptr, i64, i64 } %ret_val
}

define void @Vec__push__u8(ptr %0, i8 %1) {
bb0:
  %item = alloca i8, align 1
  %item_size = alloca i64, align 8
  %_5 = alloca i1, align 1
  %_6 = alloca i64, align 8
  %new_cap = alloca i64, align 8
  %raw = alloca ptr, align 8
  %_9 = alloca i64, align 8
  %_10 = alloca i64, align 8
  %_11 = alloca i1, align 1
  %_12 = alloca i64, align 8
  %_13 = alloca i64, align 8
  %new_cap1 = alloca i64, align 8
  %_15 = alloca i64, align 8
  %raw2 = alloca ptr, align 8
  %_17 = alloca ptr, align 8
  %_18 = alloca ptr, align 8
  %_19 = alloca i64, align 8
  %_20 = alloca i64, align 8
  %_21 = alloca i64, align 8
  %_22 = alloca i64, align 8
  %zero_p = alloca ptr, align 8
  %_24 = alloca ptr, align 8
  %_25 = alloca i64, align 8
  %_26 = alloca i64, align 8
  store i8 %1, ptr %item, align 1
  store i64 1, ptr %item_size, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %struct_f_1 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i64, ptr %struct_f_1, align 8
  store i64 %load__1.1, ptr %_6, align 8
  %load__6 = load i64, ptr %_6, align 8
  %eqtmp = icmp eq i64 %load__6, 0
  store i1 %eqtmp, ptr %_5, align 1
  %load__5 = load i1, ptr %_5, align 1
  switch i1 %load__5, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  store i64 4, ptr %new_cap, align 8
  %load__7 = load i64, ptr %new_cap, align 8
  %addtmp = add i64 %load__7, 1
  store i64 %addtmp, ptr %_10, align 8
  %load__10 = load i64, ptr %_10, align 8
  %load__3 = load i64, ptr %item_size, align 8
  %multmp = mul i64 %load__10, %load__3
  store i64 %multmp, ptr %_9, align 8
  %load__9 = load i64, ptr %_9, align 8
  %calltmp = call ptr @malloc(i64 %load__9)
  store ptr %calltmp, ptr %raw, align 8
  br label %bb5

bb3:                                              ; preds = %bb1
  %struct_f_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  %load__1.2 = load i64, ptr %struct_f_2, align 8
  store i64 %load__1.2, ptr %_12, align 8
  %struct_f_13 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.14 = load i64, ptr %struct_f_13, align 8
  store i64 %load__1.14, ptr %_13, align 8
  %load__12 = load i64, ptr %_12, align 8
  %load__13 = load i64, ptr %_13, align 8
  %eqtmp5 = icmp eq i64 %load__12, %load__13
  store i1 %eqtmp5, ptr %_11, align 1
  %load__11 = load i1, ptr %_11, align 1
  switch i1 %load__11, label %bb7 [
    i1 true, label %bb6
  ]

bb4:                                              ; preds = %bb8, %bb5
  %struct_f_26 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  %load__1.27 = load i64, ptr %struct_f_26, align 8
  store i64 %load__1.27, ptr %_21, align 8
  %load__2 = load i8, ptr %item, align 1
  %struct_f_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %idx_load = load i64, ptr %_21, align 8
  %raw_ptr_load = load ptr, ptr %struct_f_0, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  store i8 %load__2, ptr %ptr_idx, align 1
  %struct_f_28 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  %load__1.29 = load i64, ptr %struct_f_28, align 8
  store i64 %load__1.29, ptr %_22, align 8
  %load__22 = load i64, ptr %_22, align 8
  %addtmp10 = add i64 %load__22, 1
  %struct_f_211 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  store i64 %addtmp10, ptr %struct_f_211, align 8
  %struct_f_012 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_012, align 8
  store ptr %load__1.0, ptr %_24, align 8
  %load__24 = load ptr, ptr %_24, align 8
  store ptr %load__24, ptr %zero_p, align 8
  %struct_f_213 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  %load__1.214 = load i64, ptr %struct_f_213, align 8
  store i64 %load__1.214, ptr %_26, align 8
  %load__26 = load i64, ptr %_26, align 8
  %load__315 = load i64, ptr %item_size, align 8
  %multmp16 = mul i64 %load__26, %load__315
  store i64 %multmp16, ptr %_25, align 8
  %idx_load17 = load i64, ptr %_25, align 8
  %raw_ptr_load18 = load ptr, ptr %zero_p, align 8
  %ptr_idx19 = getelementptr i8, ptr %raw_ptr_load18, i64 %idx_load17
  store i8 0, ptr %ptr_idx19, align 1
  ret void

bb5:                                              ; preds = %bb2
  %load__8 = load ptr, ptr %raw, align 8
  %struct_f_020 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  store ptr %load__8, ptr %struct_f_020, align 8
  %load__721 = load i64, ptr %new_cap, align 8
  %struct_f_122 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  store i64 %load__721, ptr %struct_f_122, align 8
  br label %bb4

bb6:                                              ; preds = %bb3
  %struct_f_123 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.124 = load i64, ptr %struct_f_123, align 8
  store i64 %load__1.124, ptr %_15, align 8
  %load__15 = load i64, ptr %_15, align 8
  %multmp25 = mul i64 %load__15, 2
  store i64 %multmp25, ptr %new_cap1, align 8
  %struct_f_026 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %load__1.027 = load ptr, ptr %struct_f_026, align 8
  store ptr %load__1.027, ptr %_18, align 8
  %load__18 = load ptr, ptr %_18, align 8
  store ptr %load__18, ptr %_17, align 8
  %load__14 = load i64, ptr %new_cap1, align 8
  %addtmp28 = add i64 %load__14, 1
  store i64 %addtmp28, ptr %_20, align 8
  %load__20 = load i64, ptr %_20, align 8
  %load__329 = load i64, ptr %item_size, align 8
  %multmp30 = mul i64 %load__20, %load__329
  store i64 %multmp30, ptr %_19, align 8
  %load__17 = load ptr, ptr %_17, align 8
  %load__19 = load i64, ptr %_19, align 8
  %calltmp31 = call ptr @realloc(ptr %load__17, i64 %load__19)
  store ptr %calltmp31, ptr %raw2, align 8
  br label %bb9

bb7:                                              ; preds = %bb3
  br label %bb8

bb8:                                              ; preds = %bb9, %bb7
  br label %bb4

bb9:                                              ; preds = %bb6
  %load__16 = load ptr, ptr %raw2, align 8
  %struct_f_032 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  store ptr %load__16, ptr %struct_f_032, align 8
  %load__1433 = load i64, ptr %new_cap1, align 8
  %struct_f_134 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  store i64 %load__1433, ptr %struct_f_134, align 8
  br label %bb8
}

define void @Vec__push__val(ptr %0, i32 %1) {
bb0:
  %item = alloca i32, align 4
  %item_size = alloca i64, align 8
  %_5 = alloca i1, align 1
  %_6 = alloca i64, align 8
  %new_cap = alloca i64, align 8
  %raw = alloca ptr, align 8
  %_9 = alloca i64, align 8
  %_10 = alloca i64, align 8
  %_11 = alloca i1, align 1
  %_12 = alloca i64, align 8
  %_13 = alloca i64, align 8
  %new_cap1 = alloca i64, align 8
  %_15 = alloca i64, align 8
  %raw2 = alloca ptr, align 8
  %_17 = alloca ptr, align 8
  %_18 = alloca ptr, align 8
  %_19 = alloca i64, align 8
  %_20 = alloca i64, align 8
  %_21 = alloca i64, align 8
  %_22 = alloca i64, align 8
  %zero_p = alloca ptr, align 8
  %_24 = alloca ptr, align 8
  %_25 = alloca i64, align 8
  %_26 = alloca i64, align 8
  store i32 %1, ptr %item, align 4
  store i64 8, ptr %item_size, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %struct_f_1 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.1 = load i64, ptr %struct_f_1, align 8
  store i64 %load__1.1, ptr %_6, align 8
  %load__6 = load i64, ptr %_6, align 8
  %eqtmp = icmp eq i64 %load__6, 0
  store i1 %eqtmp, ptr %_5, align 1
  %load__5 = load i1, ptr %_5, align 1
  switch i1 %load__5, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  store i64 4, ptr %new_cap, align 8
  %load__7 = load i64, ptr %new_cap, align 8
  %addtmp = add i64 %load__7, 1
  store i64 %addtmp, ptr %_10, align 8
  %load__10 = load i64, ptr %_10, align 8
  %load__3 = load i64, ptr %item_size, align 8
  %multmp = mul i64 %load__10, %load__3
  store i64 %multmp, ptr %_9, align 8
  %load__9 = load i64, ptr %_9, align 8
  %calltmp = call ptr @malloc(i64 %load__9)
  store ptr %calltmp, ptr %raw, align 8
  br label %bb5

bb3:                                              ; preds = %bb1
  %struct_f_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  %load__1.2 = load i64, ptr %struct_f_2, align 8
  store i64 %load__1.2, ptr %_12, align 8
  %struct_f_13 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.14 = load i64, ptr %struct_f_13, align 8
  store i64 %load__1.14, ptr %_13, align 8
  %load__12 = load i64, ptr %_12, align 8
  %load__13 = load i64, ptr %_13, align 8
  %eqtmp5 = icmp eq i64 %load__12, %load__13
  store i1 %eqtmp5, ptr %_11, align 1
  %load__11 = load i1, ptr %_11, align 1
  switch i1 %load__11, label %bb7 [
    i1 true, label %bb6
  ]

bb4:                                              ; preds = %bb8, %bb5
  %struct_f_26 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  %load__1.27 = load i64, ptr %struct_f_26, align 8
  store i64 %load__1.27, ptr %_21, align 8
  %load__2 = load i32, ptr %item, align 4
  %struct_f_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %idx_load = load i64, ptr %_21, align 8
  %raw_ptr_load = load ptr, ptr %struct_f_0, align 8
  %ptr_idx = getelementptr i32, ptr %raw_ptr_load, i64 %idx_load
  store i32 %load__2, ptr %ptr_idx, align 4
  %struct_f_28 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  %load__1.29 = load i64, ptr %struct_f_28, align 8
  store i64 %load__1.29, ptr %_22, align 8
  %load__22 = load i64, ptr %_22, align 8
  %addtmp10 = add i64 %load__22, 1
  %struct_f_211 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  store i64 %addtmp10, ptr %struct_f_211, align 8
  %struct_f_012 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %load__1.0 = load ptr, ptr %struct_f_012, align 8
  store ptr %load__1.0, ptr %_24, align 8
  %load__24 = load ptr, ptr %_24, align 8
  store ptr %load__24, ptr %zero_p, align 8
  %struct_f_213 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 2
  %load__1.214 = load i64, ptr %struct_f_213, align 8
  store i64 %load__1.214, ptr %_26, align 8
  %load__26 = load i64, ptr %_26, align 8
  %load__315 = load i64, ptr %item_size, align 8
  %multmp16 = mul i64 %load__26, %load__315
  store i64 %multmp16, ptr %_25, align 8
  %idx_load17 = load i64, ptr %_25, align 8
  %raw_ptr_load18 = load ptr, ptr %zero_p, align 8
  %ptr_idx19 = getelementptr i8, ptr %raw_ptr_load18, i64 %idx_load17
  store i8 0, ptr %ptr_idx19, align 1
  ret void

bb5:                                              ; preds = %bb2
  %load__8 = load ptr, ptr %raw, align 8
  %struct_f_020 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  store ptr %load__8, ptr %struct_f_020, align 8
  %load__721 = load i64, ptr %new_cap, align 8
  %struct_f_122 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  store i64 %load__721, ptr %struct_f_122, align 8
  br label %bb4

bb6:                                              ; preds = %bb3
  %struct_f_123 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  %load__1.124 = load i64, ptr %struct_f_123, align 8
  store i64 %load__1.124, ptr %_15, align 8
  %load__15 = load i64, ptr %_15, align 8
  %multmp25 = mul i64 %load__15, 2
  store i64 %multmp25, ptr %new_cap1, align 8
  %struct_f_026 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  %load__1.027 = load ptr, ptr %struct_f_026, align 8
  store ptr %load__1.027, ptr %_18, align 8
  %load__18 = load ptr, ptr %_18, align 8
  store ptr %load__18, ptr %_17, align 8
  %load__14 = load i64, ptr %new_cap1, align 8
  %addtmp28 = add i64 %load__14, 1
  store i64 %addtmp28, ptr %_20, align 8
  %load__20 = load i64, ptr %_20, align 8
  %load__329 = load i64, ptr %item_size, align 8
  %multmp30 = mul i64 %load__20, %load__329
  store i64 %multmp30, ptr %_19, align 8
  %load__17 = load ptr, ptr %_17, align 8
  %load__19 = load i64, ptr %_19, align 8
  %calltmp31 = call ptr @realloc(ptr %load__17, i64 %load__19)
  store ptr %calltmp31, ptr %raw2, align 8
  br label %bb9

bb7:                                              ; preds = %bb3
  br label %bb8

bb8:                                              ; preds = %bb9, %bb7
  br label %bb4

bb9:                                              ; preds = %bb6
  %load__16 = load ptr, ptr %raw2, align 8
  %struct_f_032 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 0
  store ptr %load__16, ptr %struct_f_032, align 8
  %load__1433 = load i64, ptr %new_cap1, align 8
  %struct_f_134 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %0, i32 0, i32 1
  store i64 %load__1433, ptr %struct_f_134, align 8
  br label %bb8
}

define i32 @abs(i32 %0) {
bb0:
  %_0 = alloca i32, align 4
  %x = alloca i32, align 4
  %_2 = alloca i1, align 1
  store i32 %0, ptr %x, align 4
  %load__1 = load i32, ptr %x, align 4
  %lttmp = icmp slt i32 %load__1, 0
  store i1 %lttmp, ptr %_2, align 1
  %load__2 = load i1, ptr %_2, align 1
  switch i1 %load__2, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %load__11 = load i32, ptr %x, align 4
  %negtmp = sub i32 0, %load__11
  store i32 %negtmp, ptr %_0, align 4
  br label %bb3

bb2:                                              ; preds = %bb0
  %load__12 = load i32, ptr %x, align 4
  store i32 %load__12, ptr %_0, align 4
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

declare void @asm(ptr)

declare i64 @asm_read_u64(ptr)

declare i32 @atomic_compare_exchange_i32(ptr, i32, i32)

declare i64 @atomic_compare_exchange_i64(ptr, i64, i64)

declare void @atomic_fence()

declare i32 @atomic_fetch_add_i32(ptr, i32)

declare i64 @atomic_fetch_add_i64(ptr, i64)

declare i32 @atomic_fetch_sub_i32(ptr, i32)

declare i64 @atomic_fetch_sub_i64(ptr, i64)

declare i32 @atomic_load_i32(ptr)

declare i64 @atomic_load_i64(ptr)

declare void @atomic_store_i32(ptr, i32)

declare void @atomic_store_i64(ptr, i64)

declare i32 @atomic_swap_i32(ptr, i32)

declare i64 @atomic_swap_i64(ptr, i64)

define i32 @clamp(i32 %0, i32 %1, i32 %2) {
bb0:
  %_0 = alloca i32, align 4
  %val = alloca i32, align 4
  %min_val = alloca i32, align 4
  %max_val = alloca i32, align 4
  %_4 = alloca i1, align 1
  %_5 = alloca i1, align 1
  store i32 %0, ptr %val, align 4
  store i32 %1, ptr %min_val, align 4
  store i32 %2, ptr %max_val, align 4
  %load__1 = load i32, ptr %val, align 4
  %load__2 = load i32, ptr %min_val, align 4
  %lttmp = icmp slt i32 %load__1, %load__2
  store i1 %lttmp, ptr %_4, align 1
  %load__4 = load i1, ptr %_4, align 1
  switch i1 %load__4, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %load__21 = load i32, ptr %min_val, align 4
  store i32 %load__21, ptr %_0, align 4
  br label %bb3

bb2:                                              ; preds = %bb0
  %load__12 = load i32, ptr %val, align 4
  %load__3 = load i32, ptr %max_val, align 4
  %gttmp = icmp sgt i32 %load__12, %load__3
  store i1 %gttmp, ptr %_5, align 1
  %load__5 = load i1, ptr %_5, align 1
  switch i1 %load__5, label %bb5 [
    i1 true, label %bb4
  ]

bb3:                                              ; preds = %bb6, %bb1
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val

bb4:                                              ; preds = %bb2
  %load__33 = load i32, ptr %max_val, align 4
  store i32 %load__33, ptr %_0, align 4
  br label %bb6

bb5:                                              ; preds = %bb2
  %load__14 = load i32, ptr %val, align 4
  store i32 %load__14, ptr %_0, align 4
  br label %bb6

bb6:                                              ; preds = %bb5, %bb4
  br label %bb3
}

define void @eprint(ptr %0) {
bb0:
  %s = alloca ptr, align 8
  %err = alloca {}, align 8
  %_3 = alloca i1, align 1
  store ptr %0, ptr %s, align 8
  %load__2 = load {}, ptr %err, align 1
  %load__1 = load ptr, ptr %s, align 8
  %calltmp = call i1 @Stderr__write_str({} %load__2, ptr %load__1)
  store i1 %calltmp, ptr %_3, align 1
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

define void @eprintln(ptr %0) {
bb0:
  %s = alloca ptr, align 8
  %err = alloca {}, align 8
  %_3 = alloca i1, align 1
  store ptr %0, ptr %s, align 8
  %load__2 = load {}, ptr %err, align 1
  %load__1 = load ptr, ptr %s, align 8
  %calltmp = call i1 @Stderr__write_line({} %load__2, ptr %load__1)
  store i1 %calltmp, ptr %_3, align 1
  br label %bb1

bb1:                                              ; preds = %bb0
  ret void
}

declare ptr @format(ptr)

define { i32, { { ptr, i64, i64 } } } @get_env(ptr %0) {
bb0:
  %_0 = alloca { i32, { { ptr, i64, i64 } } }, align 8
  %name = alloca ptr, align 8
  %val_ptr = alloca ptr, align 8
  %_3 = alloca i1, align 1
  %_4 = alloca i64, align 8
  %_5 = alloca { { ptr, i64, i64 } }, align 8
  %_6 = alloca ptr, align 8
  store ptr %0, ptr %name, align 8
  %load__1 = load ptr, ptr %name, align 8
  %calltmp = call ptr @getenv(ptr %load__1)
  store ptr %calltmp, ptr %val_ptr, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__2 = load ptr, ptr %val_ptr, align 8
  %ptr2int = ptrtoint ptr %load__2 to i64
  store i64 %ptr2int, ptr %_4, align 8
  %load__4 = load i64, ptr %_4, align 8
  %eqtmp = icmp eq i64 %load__4, 0
  store i1 %eqtmp, ptr %_3, align 1
  %load__3 = load i1, ptr %_3, align 1
  switch i1 %load__3, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  %f_gep_0 = getelementptr inbounds nuw { i32, { { ptr, i64, i64 } } }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_0, align 4
  %f_gep_1 = getelementptr inbounds nuw { i32, { { ptr, i64, i64 } } }, ptr %_0, i32 0, i32 1
  store { { ptr, i64, i64 } } zeroinitializer, ptr %f_gep_1, align 8
  br label %bb4

bb3:                                              ; preds = %bb1
  %load__21 = load ptr, ptr %val_ptr, align 8
  store ptr %load__21, ptr %_6, align 8
  %load__6 = load ptr, ptr %_6, align 8
  %calltmp2 = call { { ptr, i64, i64 } } @String__from_str(ptr %load__6)
  store { { ptr, i64, i64 } } %calltmp2, ptr %_5, align 8
  br label %bb5

bb4:                                              ; preds = %bb5, %bb2
  %ret_val = load { i32, { { ptr, i64, i64 } } }, ptr %_0, align 8
  ret { i32, { { ptr, i64, i64 } } } %ret_val

bb5:                                              ; preds = %bb3
  %f_gep_03 = getelementptr inbounds nuw { i32, { { ptr, i64, i64 } } }, ptr %_0, i32 0, i32 0
  store i32 1, ptr %f_gep_03, align 4
  %load__5 = load { { ptr, i64, i64 } }, ptr %_5, align 8
  %f_gep_14 = getelementptr inbounds nuw { i32, { { ptr, i64, i64 } } }, ptr %_0, i32 0, i32 1
  store { { ptr, i64, i64 } } %load__5, ptr %f_gep_14, align 8
  br label %bb4
}

define { { ptr, i64, i64 } } @int_to_str(i32 %0) {
bb0:
  %_0 = alloca { { ptr, i64, i64 } }, align 8
  %val = alloca i32, align 4
  %v = alloca i32, align 4
  %res = alloca { { ptr, i64, i64 } }, align 8
  %_5 = alloca i1, align 1
  %is_neg = alloca i1, align 1
  %_10 = alloca i1, align 1
  %digits = alloca { ptr, i64, i64 }, align 8
  %_13 = alloca i1, align 1
  %d = alloca i8, align 1
  %_15 = alloca i32, align 4
  %_17 = alloca i8, align 1
  %i = alloca i64, align 8
  %_21 = alloca i1, align 1
  %_23 = alloca i8, align 1
  store i32 %0, ptr %val, align 4
  %load__1 = load i32, ptr %val, align 4
  store i32 %load__1, ptr %v, align 4
  %calltmp = call { { ptr, i64, i64 } } @String__new()
  store { { ptr, i64, i64 } } %calltmp, ptr %res, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__2 = load i32, ptr %v, align 4
  %eqtmp = icmp eq i32 %load__2, 0
  store i1 %eqtmp, ptr %_5, align 1
  %load__5 = load i1, ptr %_5, align 1
  switch i1 %load__5, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  call void @String__push_byte(ptr %res, i8 48)
  br label %bb5

bb3:                                              ; preds = %bb1
  br label %bb4

bb4:                                              ; preds = %bb3
  store i1 false, ptr %is_neg, align 1
  %load__21 = load i32, ptr %v, align 4
  %lttmp = icmp slt i32 %load__21, 0
  store i1 %lttmp, ptr %_10, align 1
  %load__10 = load i1, ptr %_10, align 1
  switch i1 %load__10, label %bb8 [
    i1 true, label %bb7
  ]

bb5:                                              ; preds = %bb2
  call void @String__push_byte(ptr %res, i8 0)
  br label %bb6

bb6:                                              ; preds = %bb5
  %load__3 = load { { ptr, i64, i64 } }, ptr %res, align 8
  store { { ptr, i64, i64 } } %load__3, ptr %_0, align 8
  %ret_val = load { { ptr, i64, i64 } }, ptr %_0, align 8
  ret { { ptr, i64, i64 } } %ret_val

bb7:                                              ; preds = %bb4
  store i1 true, ptr %is_neg, align 1
  %load__22 = load i32, ptr %v, align 4
  %subtmp = sub i32 0, %load__22
  store i32 %subtmp, ptr %v, align 4
  br label %bb9

bb8:                                              ; preds = %bb4
  br label %bb9

bb9:                                              ; preds = %bb8, %bb7
  %calltmp3 = call { ptr, i64, i64 } @Vec__new__u8()
  store { ptr, i64, i64 } %calltmp3, ptr %digits, align 8
  br label %bb10

bb10:                                             ; preds = %bb9
  br label %bb11

bb11:                                             ; preds = %bb14, %bb10
  %load__24 = load i32, ptr %v, align 4
  %gttmp = icmp sgt i32 %load__24, 0
  store i1 %gttmp, ptr %_13, align 1
  %load__13 = load i1, ptr %_13, align 1
  switch i1 %load__13, label %bb13 [
    i1 true, label %bb12
  ]

bb12:                                             ; preds = %bb11
  %load__25 = load i32, ptr %v, align 4
  %remtmp = srem i32 %load__25, 10
  store i32 %remtmp, ptr %_15, align 4
  %load__15 = load i32, ptr %_15, align 4
  %casttmp = trunc i32 %load__15 to i8
  store i8 %casttmp, ptr %d, align 1
  %load__14 = load i8, ptr %d, align 1
  %addtmp = add i8 %load__14, 48
  store i8 %addtmp, ptr %_17, align 1
  %load__17 = load i8, ptr %_17, align 1
  call void @Vec__push__u8(ptr %digits, i8 %load__17)
  br label %bb14

bb13:                                             ; preds = %bb11
  %load__8 = load i1, ptr %is_neg, align 1
  switch i1 %load__8, label %bb16 [
    i1 true, label %bb15
  ]

bb14:                                             ; preds = %bb12
  %load__26 = load i32, ptr %v, align 4
  %divtmp = sdiv i32 %load__26, 10
  store i32 %divtmp, ptr %v, align 4
  br label %bb11

bb15:                                             ; preds = %bb13
  call void @String__push_byte(ptr %res, i8 45)
  br label %bb18

bb16:                                             ; preds = %bb13
  br label %bb17

bb17:                                             ; preds = %bb18, %bb16
  %struct_f_2 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %digits, i32 0, i32 2
  %load__11.2 = load i64, ptr %struct_f_2, align 8
  store i64 %load__11.2, ptr %i, align 8
  br label %bb19

bb18:                                             ; preds = %bb15
  br label %bb17

bb19:                                             ; preds = %bb22, %bb17
  %load__19 = load i64, ptr %i, align 8
  %gttmp7 = icmp sgt i64 %load__19, 0
  store i1 %gttmp7, ptr %_21, align 1
  %load__218 = load i1, ptr %_21, align 1
  switch i1 %load__218, label %bb21 [
    i1 true, label %bb20
  ]

bb20:                                             ; preds = %bb19
  %load__199 = load i64, ptr %i, align 8
  %subtmp10 = sub i64 %load__199, 1
  store i64 %subtmp10, ptr %i, align 8
  %struct_f_0 = getelementptr inbounds nuw { ptr, i64, i64 }, ptr %digits, i32 0, i32 0
  %idx_load = load i64, ptr %i, align 8
  %raw_ptr_load = load ptr, ptr %struct_f_0, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__11.0[_19]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__11.0[_19]", ptr %_23, align 1
  %load__23 = load i8, ptr %_23, align 1
  call void @String__push_byte(ptr %res, i8 %load__23)
  br label %bb22

bb21:                                             ; preds = %bb19
  call void @String__push_byte(ptr %res, i8 0)
  br label %bb23

bb22:                                             ; preds = %bb20
  br label %bb19

bb23:                                             ; preds = %bb21
  %load__311 = load { { ptr, i64, i64 } }, ptr %res, align 8
  store { { ptr, i64, i64 } } %load__311, ptr %_0, align 8
  %ret_val12 = load { { ptr, i64, i64 } }, ptr %_0, align 8
  ret { { ptr, i64, i64 } } %ret_val12
}

define i1 @is_alnum(i8 %0) {
bb0:
  %_0 = alloca i1, align 1
  %ch = alloca i8, align 1
  %_2 = alloca i1, align 1
  %_3 = alloca i1, align 1
  store i8 %0, ptr %ch, align 1
  %load__1 = load i8, ptr %ch, align 1
  %calltmp = call i1 @is_alpha(i8 %load__1)
  store i1 %calltmp, ptr %_2, align 1
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__11 = load i8, ptr %ch, align 1
  %calltmp2 = call i1 @is_digit(i8 %load__11)
  store i1 %calltmp2, ptr %_3, align 1
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__2 = load i1, ptr %_2, align 1
  %load__3 = load i1, ptr %_3, align 1
  %ortmp = or i1 %load__2, %load__3
  store i1 %ortmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define i1 @is_alpha(i8 %0) {
bb0:
  %_0 = alloca i1, align 1
  %ch = alloca i8, align 1
  %_2 = alloca i1, align 1
  %_3 = alloca i1, align 1
  %_4 = alloca i1, align 1
  %_5 = alloca i1, align 1
  %_6 = alloca i1, align 1
  %_7 = alloca i1, align 1
  %_8 = alloca i1, align 1
  %_9 = alloca i1, align 1
  store i8 %0, ptr %ch, align 1
  %load__1 = load i8, ptr %ch, align 1
  %getmp = icmp sge i8 %load__1, 65
  store i1 %getmp, ptr %_4, align 1
  %load__11 = load i8, ptr %ch, align 1
  %letmp = icmp sle i8 %load__11, 90
  store i1 %letmp, ptr %_5, align 1
  %load__4 = load i1, ptr %_4, align 1
  %load__5 = load i1, ptr %_5, align 1
  %andtmp = and i1 %load__4, %load__5
  store i1 %andtmp, ptr %_3, align 1
  %load__12 = load i8, ptr %ch, align 1
  %getmp3 = icmp sge i8 %load__12, 97
  store i1 %getmp3, ptr %_7, align 1
  %load__14 = load i8, ptr %ch, align 1
  %letmp5 = icmp sle i8 %load__14, 122
  store i1 %letmp5, ptr %_8, align 1
  %load__7 = load i1, ptr %_7, align 1
  %load__8 = load i1, ptr %_8, align 1
  %andtmp6 = and i1 %load__7, %load__8
  store i1 %andtmp6, ptr %_6, align 1
  %load__3 = load i1, ptr %_3, align 1
  %load__6 = load i1, ptr %_6, align 1
  %ortmp = or i1 %load__3, %load__6
  store i1 %ortmp, ptr %_2, align 1
  %load__17 = load i8, ptr %ch, align 1
  %eqtmp = icmp eq i8 %load__17, 95
  store i1 %eqtmp, ptr %_9, align 1
  %load__2 = load i1, ptr %_2, align 1
  %load__9 = load i1, ptr %_9, align 1
  %ortmp8 = or i1 %load__2, %load__9
  store i1 %ortmp8, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define i1 @is_digit(i8 %0) {
bb0:
  %_0 = alloca i1, align 1
  %ch = alloca i8, align 1
  %_2 = alloca i1, align 1
  %_3 = alloca i1, align 1
  store i8 %0, ptr %ch, align 1
  %load__1 = load i8, ptr %ch, align 1
  %getmp = icmp sge i8 %load__1, 48
  store i1 %getmp, ptr %_2, align 1
  %load__11 = load i8, ptr %ch, align 1
  %letmp = icmp sle i8 %load__11, 57
  store i1 %letmp, ptr %_3, align 1
  %load__2 = load i1, ptr %_2, align 1
  %load__3 = load i1, ptr %_3, align 1
  %andtmp = and i1 %load__2, %load__3
  store i1 %andtmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define i32 @max(i32 %0, i32 %1) {
bb0:
  %_0 = alloca i32, align 4
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  %_3 = alloca i1, align 1
  store i32 %0, ptr %a, align 4
  store i32 %1, ptr %b, align 4
  %load__1 = load i32, ptr %a, align 4
  %load__2 = load i32, ptr %b, align 4
  %gttmp = icmp sgt i32 %load__1, %load__2
  store i1 %gttmp, ptr %_3, align 1
  %load__3 = load i1, ptr %_3, align 1
  switch i1 %load__3, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %load__11 = load i32, ptr %a, align 4
  store i32 %load__11, ptr %_0, align 4
  br label %bb3

bb2:                                              ; preds = %bb0
  %load__22 = load i32, ptr %b, align 4
  store i32 %load__22, ptr %_0, align 4
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

define i32 @min(i32 %0, i32 %1) {
bb0:
  %_0 = alloca i32, align 4
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  %_3 = alloca i1, align 1
  store i32 %0, ptr %a, align 4
  store i32 %1, ptr %b, align 4
  %load__1 = load i32, ptr %a, align 4
  %load__2 = load i32, ptr %b, align 4
  %lttmp = icmp slt i32 %load__1, %load__2
  store i1 %lttmp, ptr %_3, align 1
  %load__3 = load i1, ptr %_3, align 1
  switch i1 %load__3, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  %load__11 = load i32, ptr %a, align 4
  store i32 %load__11, ptr %_0, align 4
  br label %bb3

bb2:                                              ; preds = %bb0
  %load__22 = load i32, ptr %b, align 4
  store i32 %load__22, ptr %_0, align 4
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

declare void @panic(ptr)

define i64 @parse_int(ptr %0) {
bb0:
  %_0 = alloca i64, align 8
  %s = alloca ptr, align 8
  %p = alloca ptr, align 8
  %len = alloca i64, align 8
  %res = alloca i64, align 8
  %i = alloca i64, align 8
  %is_neg = alloca i1, align 1
  %_8 = alloca i1, align 1
  %_9 = alloca i1, align 1
  %_10 = alloca i1, align 1
  %_11 = alloca i8, align 1
  %_12 = alloca i64, align 8
  %_14 = alloca i1, align 1
  %_15 = alloca i1, align 1
  %_16 = alloca i1, align 1
  %_17 = alloca i8, align 1
  %_18 = alloca i64, align 8
  %_19 = alloca i64, align 8
  %_20 = alloca i8, align 1
  %_21 = alloca i8, align 1
  store ptr %0, ptr %s, align 8
  %load__1 = load ptr, ptr %s, align 8
  store ptr %load__1, ptr %p, align 8
  %load__11 = load ptr, ptr %s, align 8
  %calltmp = call i64 @str_len(ptr %load__11)
  store i64 %calltmp, ptr %len, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  store i64 0, ptr %res, align 8
  store i64 0, ptr %i, align 8
  store i1 false, ptr %is_neg, align 1
  %load__3 = load i64, ptr %len, align 8
  %gttmp = icmp sgt i64 %load__3, 0
  store i1 %gttmp, ptr %_9, align 1
  store i64 0, ptr %_12, align 8
  %idx_load = load i64, ptr %_12, align 8
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__2[_12]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__2[_12]", ptr %_11, align 1
  %load__112 = load i8, ptr %_11, align 1
  %eqtmp = icmp eq i8 %load__112, 45
  store i1 %eqtmp, ptr %_10, align 1
  %load__9 = load i1, ptr %_9, align 1
  %load__10 = load i1, ptr %_10, align 1
  %andtmp = and i1 %load__9, %load__10
  store i1 %andtmp, ptr %_8, align 1
  %load__8 = load i1, ptr %_8, align 1
  switch i1 %load__8, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  store i1 true, ptr %is_neg, align 1
  store i64 1, ptr %i, align 8
  br label %bb4

bb3:                                              ; preds = %bb1
  br label %bb4

bb4:                                              ; preds = %bb3, %bb2
  br label %bb5

bb5:                                              ; preds = %bb6, %bb4
  %load__5 = load i64, ptr %i, align 8
  %load__33 = load i64, ptr %len, align 8
  %lttmp = icmp slt i64 %load__5, %load__33
  store i1 %lttmp, ptr %_15, align 1
  %idx_load4 = load i64, ptr %i, align 8
  %raw_ptr_load5 = load ptr, ptr %p, align 8
  %ptr_idx6 = getelementptr i8, ptr %raw_ptr_load5, i64 %idx_load4
  %"load__2[_5]" = load i8, ptr %ptr_idx6, align 1
  store i8 %"load__2[_5]", ptr %_17, align 1
  %load__17 = load i8, ptr %_17, align 1
  %calltmp7 = call i1 @is_digit(i8 %load__17)
  store i1 %calltmp7, ptr %_16, align 1
  br label %bb8

bb6:                                              ; preds = %bb8
  %load__4 = load i64, ptr %res, align 8
  %multmp = mul i64 %load__4, 10
  store i64 %multmp, ptr %_18, align 8
  %idx_load8 = load i64, ptr %i, align 8
  %raw_ptr_load9 = load ptr, ptr %p, align 8
  %ptr_idx10 = getelementptr i8, ptr %raw_ptr_load9, i64 %idx_load8
  %"load__2[_5]11" = load i8, ptr %ptr_idx10, align 1
  store i8 %"load__2[_5]11", ptr %_21, align 1
  %load__21 = load i8, ptr %_21, align 1
  %subtmp = sub i8 %load__21, 48
  store i8 %subtmp, ptr %_20, align 1
  %load__20 = load i8, ptr %_20, align 1
  %casttmp = sext i8 %load__20 to i64
  store i64 %casttmp, ptr %_19, align 8
  %load__18 = load i64, ptr %_18, align 8
  %load__19 = load i64, ptr %_19, align 8
  %addtmp = add i64 %load__18, %load__19
  store i64 %addtmp, ptr %res, align 8
  %load__512 = load i64, ptr %i, align 8
  %addtmp13 = add i64 %load__512, 1
  store i64 %addtmp13, ptr %i, align 8
  br label %bb5

bb7:                                              ; preds = %bb8
  %load__6 = load i1, ptr %is_neg, align 1
  switch i1 %load__6, label %bb10 [
    i1 true, label %bb9
  ]

bb8:                                              ; preds = %bb5
  %load__15 = load i1, ptr %_15, align 1
  %load__16 = load i1, ptr %_16, align 1
  %andtmp14 = and i1 %load__15, %load__16
  store i1 %andtmp14, ptr %_14, align 1
  %load__14 = load i1, ptr %_14, align 1
  switch i1 %load__14, label %bb7 [
    i1 true, label %bb6
  ]

bb9:                                              ; preds = %bb7
  %load__415 = load i64, ptr %res, align 8
  %subtmp16 = sub i64 0, %load__415
  store i64 %subtmp16, ptr %_0, align 8
  br label %bb11

bb10:                                             ; preds = %bb7
  %load__417 = load i64, ptr %res, align 8
  store i64 %load__417, ptr %_0, align 8
  br label %bb11

bb11:                                             ; preds = %bb10, %bb9
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val
}

declare i32 @ptr_read__val(ptr)

declare void @ptr_write__struct155_val(ptr, { ptr, ptr, { ptr, i64, i64 }, i64, i1 })

declare void @ptr_write__val(ptr, i32)

define { i32, { { ptr, i64, i64 } } } @read_file(ptr %0) {
bb0:
  %_0 = alloca { i32, { { ptr, i64, i64 } } }, align 8
  %path = alloca ptr, align 8
  %f_opt = alloca { i32, { ptr, i1 } }, align 8
  %_3 = alloca i32, align 4
  %f = alloca { ptr, i1 }, align 8
  %file = alloca { ptr, i1 }, align 8
  %content = alloca { { ptr, i64, i64 } }, align 8
  %_8 = alloca i32, align 4
  store ptr %0, ptr %path, align 8
  %load__1 = load ptr, ptr %path, align 8
  %calltmp = call { i32, { ptr, i1 } } @File__open_read(ptr %load__1)
  store { i32, { ptr, i1 } } %calltmp, ptr %f_opt, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  br label %bb3

bb2:                                              ; preds = %bb12, %bb11, %bb10
  %ret_val = load { i32, { { ptr, i64, i64 } } }, ptr %_0, align 8
  ret { i32, { { ptr, i64, i64 } } } %ret_val

bb3:                                              ; preds = %bb1
  %tag_gep = getelementptr inbounds nuw { i32, { ptr, i1 } }, ptr %f_opt, i32 0, i32 0
  %tag_val = load i32, ptr %tag_gep, align 4
  store i32 %tag_val, ptr %_3, align 4
  %load__3 = load i32, ptr %_3, align 4
  switch i32 %load__3, label %bb4 [
    i32 1, label %bb8
  ]

bb4:                                              ; preds = %bb3
  %tag_gep1 = getelementptr inbounds nuw { i32, { ptr, i1 } }, ptr %f_opt, i32 0, i32 0
  %tag_val2 = load i32, ptr %tag_gep1, align 4
  store i32 %tag_val2, ptr %_8, align 4
  %load__8 = load i32, ptr %_8, align 4
  switch i32 %load__8, label %bb5 [
    i32 0, label %bb11
  ]

bb5:                                              ; preds = %bb4
  br label %bb12

bb6:                                              ; No predecessors!
  unreachable

bb7:                                              ; preds = %bb8
  %load__4 = load { ptr, i1 }, ptr %f, align 8
  store { ptr, i1 } %load__4, ptr %file, align 8
  %calltmp3 = call { { ptr, i64, i64 } } @File__read_to_string(ptr %file)
  store { { ptr, i64, i64 } } %calltmp3, ptr %content, align 8
  br label %bb9

bb8:                                              ; preds = %bb3
  %enum_f_0 = getelementptr inbounds nuw { i32, { ptr, i1 } }, ptr %f_opt, i32 0, i32 1
  %load__2.0 = load { ptr, i1 }, ptr %enum_f_0, align 8
  store { ptr, i1 } %load__2.0, ptr %f, align 8
  br label %bb7

bb9:                                              ; preds = %bb7
  call void @File__close(ptr %file)
  br label %bb10

bb10:                                             ; preds = %bb9
  %f_gep_0 = getelementptr inbounds nuw { i32, { { ptr, i64, i64 } } }, ptr %_0, i32 0, i32 0
  store i32 1, ptr %f_gep_0, align 4
  %load__6 = load { { ptr, i64, i64 } }, ptr %content, align 8
  %f_gep_1 = getelementptr inbounds nuw { i32, { { ptr, i64, i64 } } }, ptr %_0, i32 0, i32 1
  store { { ptr, i64, i64 } } %load__6, ptr %f_gep_1, align 8
  br label %bb2

bb11:                                             ; preds = %bb4
  %f_gep_04 = getelementptr inbounds nuw { i32, { { ptr, i64, i64 } } }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_04, align 4
  %f_gep_15 = getelementptr inbounds nuw { i32, { { ptr, i64, i64 } } }, ptr %_0, i32 0, i32 1
  store { { ptr, i64, i64 } } zeroinitializer, ptr %f_gep_15, align 8
  br label %bb2

bb12:                                             ; preds = %bb5
  %f_gep_06 = getelementptr inbounds nuw { i32, { { ptr, i64, i64 } } }, ptr %_0, i32 0, i32 0
  store i32 0, ptr %f_gep_06, align 4
  %f_gep_17 = getelementptr inbounds nuw { i32, { { ptr, i64, i64 } } }, ptr %_0, i32 0, i32 1
  store { { ptr, i64, i64 } } zeroinitializer, ptr %f_gep_17, align 8
  br label %bb2
}

define { { ptr, i64, i64 } } @read_file_string(ptr %0) {
bb0:
  %_0 = alloca { { ptr, i64, i64 } }, align 8
  %path = alloca ptr, align 8
  %res = alloca { { ptr, i64, i64 } }, align 8
  %fp = alloca ptr, align 8
  %_5 = alloca i1, align 1
  %_6 = alloca i64, align 8
  %_7 = alloca i32, align 4
  %size = alloca i64, align 8
  %_9 = alloca i64, align 8
  %_10 = alloca i32, align 4
  %_12 = alloca i1, align 1
  %_13 = alloca i32, align 4
  %buf = alloca ptr, align 8
  %_15 = alloca ptr, align 8
  %_16 = alloca i64, align 8
  %read_bytes = alloca i64, align 8
  %_18 = alloca i64, align 8
  %_19 = alloca i32, align 4
  %i = alloca i64, align 8
  %_22 = alloca i1, align 1
  %_24 = alloca i8, align 1
  store ptr %0, ptr %path, align 8
  %calltmp = call { { ptr, i64, i64 } } @String__new()
  store { { ptr, i64, i64 } } %calltmp, ptr %res, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__1 = load ptr, ptr %path, align 8
  %calltmp1 = call ptr @fopen(ptr %load__1, ptr @str_lit.6)
  store ptr %calltmp1, ptr %fp, align 8
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__3 = load ptr, ptr %fp, align 8
  %ptr2int = ptrtoint ptr %load__3 to i64
  store i64 %ptr2int, ptr %_6, align 8
  %load__6 = load i64, ptr %_6, align 8
  %eqtmp = icmp eq i64 %load__6, 0
  store i1 %eqtmp, ptr %_5, align 1
  %load__5 = load i1, ptr %_5, align 1
  switch i1 %load__5, label %bb4 [
    i1 true, label %bb3
  ]

bb3:                                              ; preds = %bb2
  %load__2 = load { { ptr, i64, i64 } }, ptr %res, align 8
  store { { ptr, i64, i64 } } %load__2, ptr %_0, align 8
  %ret_val = load { { ptr, i64, i64 } }, ptr %_0, align 8
  ret { { ptr, i64, i64 } } %ret_val

bb4:                                              ; preds = %bb2
  br label %bb5

bb5:                                              ; preds = %bb4
  %load__32 = load ptr, ptr %fp, align 8
  %calltmp3 = call i32 @fseek(ptr %load__32, i64 0, i32 2)
  store i32 %calltmp3, ptr %_7, align 4
  br label %bb6

bb6:                                              ; preds = %bb5
  %load__34 = load ptr, ptr %fp, align 8
  %calltmp5 = call i64 @ftell(ptr %load__34)
  store i64 %calltmp5, ptr %_9, align 8
  br label %bb7

bb7:                                              ; preds = %bb6
  %load__9 = load i64, ptr %_9, align 8
  store i64 %load__9, ptr %size, align 8
  %load__36 = load ptr, ptr %fp, align 8
  %calltmp7 = call i32 @fseek(ptr %load__36, i64 0, i32 0)
  store i32 %calltmp7, ptr %_10, align 4
  br label %bb8

bb8:                                              ; preds = %bb7
  %load__8 = load i64, ptr %size, align 8
  %eqtmp8 = icmp eq i64 %load__8, 0
  store i1 %eqtmp8, ptr %_12, align 1
  %load__12 = load i1, ptr %_12, align 1
  switch i1 %load__12, label %bb10 [
    i1 true, label %bb9
  ]

bb9:                                              ; preds = %bb8
  %load__39 = load ptr, ptr %fp, align 8
  %calltmp10 = call i32 @fclose(ptr %load__39)
  store i32 %calltmp10, ptr %_13, align 4
  br label %bb12

bb10:                                             ; preds = %bb8
  br label %bb11

bb11:                                             ; preds = %bb10
  %load__811 = load i64, ptr %size, align 8
  %addtmp = add i64 %load__811, 1
  store i64 %addtmp, ptr %_16, align 8
  %load__16 = load i64, ptr %_16, align 8
  %calltmp12 = call ptr @malloc(i64 %load__16)
  store ptr %calltmp12, ptr %_15, align 8
  br label %bb13

bb12:                                             ; preds = %bb9
  %load__213 = load { { ptr, i64, i64 } }, ptr %res, align 8
  store { { ptr, i64, i64 } } %load__213, ptr %_0, align 8
  %ret_val14 = load { { ptr, i64, i64 } }, ptr %_0, align 8
  ret { { ptr, i64, i64 } } %ret_val14

bb13:                                             ; preds = %bb11
  %load__15 = load ptr, ptr %_15, align 8
  store ptr %load__15, ptr %buf, align 8
  %load__14 = load ptr, ptr %buf, align 8
  %load__815 = load i64, ptr %size, align 8
  %load__316 = load ptr, ptr %fp, align 8
  %calltmp17 = call i64 @fread(ptr %load__14, i64 1, i64 %load__815, ptr %load__316)
  store i64 %calltmp17, ptr %_18, align 8
  br label %bb14

bb14:                                             ; preds = %bb13
  %load__18 = load i64, ptr %_18, align 8
  store i64 %load__18, ptr %read_bytes, align 8
  %idx_load = load i64, ptr %read_bytes, align 8
  %raw_ptr_load = load ptr, ptr %buf, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  store i8 0, ptr %ptr_idx, align 1
  %load__318 = load ptr, ptr %fp, align 8
  %calltmp19 = call i32 @fclose(ptr %load__318)
  store i32 %calltmp19, ptr %_19, align 4
  br label %bb15

bb15:                                             ; preds = %bb14
  store i64 0, ptr %i, align 8
  br label %bb16

bb16:                                             ; preds = %bb19, %bb15
  %load__20 = load i64, ptr %i, align 8
  %load__17 = load i64, ptr %read_bytes, align 8
  %lttmp = icmp slt i64 %load__20, %load__17
  store i1 %lttmp, ptr %_22, align 1
  %load__22 = load i1, ptr %_22, align 1
  switch i1 %load__22, label %bb18 [
    i1 true, label %bb17
  ]

bb17:                                             ; preds = %bb16
  %idx_load20 = load i64, ptr %i, align 8
  %raw_ptr_load21 = load ptr, ptr %buf, align 8
  %ptr_idx22 = getelementptr i8, ptr %raw_ptr_load21, i64 %idx_load20
  %"load__14[_20]" = load i8, ptr %ptr_idx22, align 1
  store i8 %"load__14[_20]", ptr %_24, align 1
  %load__24 = load i8, ptr %_24, align 1
  call void @String__push_byte(ptr %res, i8 %load__24)
  br label %bb19

bb18:                                             ; preds = %bb16
  call void @String__push_byte(ptr %res, i8 0)
  br label %bb20

bb19:                                             ; preds = %bb17
  %load__2023 = load i64, ptr %i, align 8
  %addtmp24 = add i64 %load__2023, 1
  store i64 %addtmp24, ptr %i, align 8
  br label %bb16

bb20:                                             ; preds = %bb18
  %load__1425 = load ptr, ptr %buf, align 8
  call void @free(ptr %load__1425)
  br label %bb21

bb21:                                             ; preds = %bb20
  %load__226 = load { { ptr, i64, i64 } }, ptr %res, align 8
  store { { ptr, i64, i64 } } %load__226, ptr %_0, align 8
  %ret_val27 = load { { ptr, i64, i64 } }, ptr %_0, align 8
  ret { { ptr, i64, i64 } } %ret_val27
}

define i1 @remove_file(ptr %0) {
bb0:
  %_0 = alloca i1, align 1
  %path = alloca ptr, align 8
  %res = alloca i32, align 4
  store ptr %0, ptr %path, align 8
  %load__1 = load ptr, ptr %path, align 8
  %calltmp = call i32 @remove(ptr %load__1)
  store i32 %calltmp, ptr %res, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__2 = load i32, ptr %res, align 4
  %eqtmp = icmp eq i32 %load__2, 0
  store i1 %eqtmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

define i1 @set_env(ptr %0, ptr %1) {
bb0:
  %_0 = alloca i1, align 1
  %name = alloca ptr, align 8
  %val = alloca ptr, align 8
  %res = alloca i32, align 4
  store ptr %0, ptr %name, align 8
  store ptr %1, ptr %val, align 8
  %load__1 = load ptr, ptr %name, align 8
  %load__2 = load ptr, ptr %val, align 8
  %calltmp = call i32 @setenv(ptr %load__1, ptr %load__2, i32 1)
  store i32 %calltmp, ptr %res, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__3 = load i32, ptr %res, align 4
  %eqtmp = icmp eq i32 %load__3, 0
  store i1 %eqtmp, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val
}

declare i64 @size_of_val__struct155_val({ ptr, ptr, { ptr, i64, i64 }, i64, i1 })

declare i64 @size_of_val__val(i32)

define i32 @sleep_ms(i64 %0) {
bb0:
  %_0 = alloca i32, align 4
  %millis = alloca i64, align 8
  %usecs = alloca i32, align 4
  %_3 = alloca i64, align 8
  store i64 %0, ptr %millis, align 8
  %load__1 = load i64, ptr %millis, align 8
  %multmp = mul i64 %load__1, 1000
  store i64 %multmp, ptr %_3, align 8
  %load__3 = load i64, ptr %_3, align 8
  %casttmp = trunc i64 %load__3 to i32
  store i32 %casttmp, ptr %usecs, align 4
  %load__2 = load i32, ptr %usecs, align 4
  %calltmp = call i32 @usleep(i32 %load__2)
  store i32 %calltmp, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

define i1 @str_ends_with(ptr %0, ptr %1) {
bb0:
  %_0 = alloca i1, align 1
  %s = alloca ptr, align 8
  %suffix = alloca ptr, align 8
  %s_len = alloca i64, align 8
  %suf_len = alloca i64, align 8
  %_6 = alloca i1, align 1
  %_7 = alloca i1, align 1
  %_8 = alloca i1, align 1
  %ps = alloca ptr, align 8
  %p_suf = alloca ptr, align 8
  %start = alloca i64, align 8
  %i = alloca i64, align 8
  %_14 = alloca i1, align 1
  %_16 = alloca i1, align 1
  %_17 = alloca i8, align 1
  %_18 = alloca i64, align 8
  %_19 = alloca i8, align 1
  store ptr %0, ptr %s, align 8
  store ptr %1, ptr %suffix, align 8
  %load__1 = load ptr, ptr %s, align 8
  %calltmp = call i64 @str_len(ptr %load__1)
  store i64 %calltmp, ptr %s_len, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__2 = load ptr, ptr %suffix, align 8
  %calltmp1 = call i64 @str_len(ptr %load__2)
  store i64 %calltmp1, ptr %suf_len, align 8
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__3 = load i64, ptr %s_len, align 8
  %load__4 = load i64, ptr %suf_len, align 8
  %lttmp = icmp slt i64 %load__3, %load__4
  store i1 %lttmp, ptr %_7, align 1
  %load__32 = load i64, ptr %s_len, align 8
  %eqtmp = icmp eq i64 %load__32, 0
  store i1 %eqtmp, ptr %_8, align 1
  %load__7 = load i1, ptr %_7, align 1
  %load__8 = load i1, ptr %_8, align 1
  %ortmp = or i1 %load__7, %load__8
  store i1 %ortmp, ptr %_6, align 1
  %load__6 = load i1, ptr %_6, align 1
  switch i1 %load__6, label %bb4 [
    i1 true, label %bb3
  ]

bb3:                                              ; preds = %bb2
  store i1 false, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val

bb4:                                              ; preds = %bb2
  br label %bb5

bb5:                                              ; preds = %bb4
  %load__13 = load ptr, ptr %s, align 8
  store ptr %load__13, ptr %ps, align 8
  %load__24 = load ptr, ptr %suffix, align 8
  store ptr %load__24, ptr %p_suf, align 8
  %load__35 = load i64, ptr %s_len, align 8
  %load__46 = load i64, ptr %suf_len, align 8
  %subtmp = sub i64 %load__35, %load__46
  store i64 %subtmp, ptr %start, align 8
  store i64 0, ptr %i, align 8
  br label %bb6

bb6:                                              ; preds = %bb11, %bb5
  %load__12 = load i64, ptr %i, align 8
  %load__47 = load i64, ptr %suf_len, align 8
  %lttmp8 = icmp slt i64 %load__12, %load__47
  store i1 %lttmp8, ptr %_14, align 1
  %load__14 = load i1, ptr %_14, align 1
  switch i1 %load__14, label %bb8 [
    i1 true, label %bb7
  ]

bb7:                                              ; preds = %bb6
  %load__11 = load i64, ptr %start, align 8
  %load__129 = load i64, ptr %i, align 8
  %addtmp = add i64 %load__11, %load__129
  store i64 %addtmp, ptr %_18, align 8
  %idx_load = load i64, ptr %_18, align 8
  %raw_ptr_load = load ptr, ptr %ps, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__9[_18]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__9[_18]", ptr %_17, align 1
  %idx_load10 = load i64, ptr %i, align 8
  %raw_ptr_load11 = load ptr, ptr %p_suf, align 8
  %ptr_idx12 = getelementptr i8, ptr %raw_ptr_load11, i64 %idx_load10
  %"load__10[_12]" = load i8, ptr %ptr_idx12, align 1
  store i8 %"load__10[_12]", ptr %_19, align 1
  %load__17 = load i8, ptr %_17, align 1
  %load__19 = load i8, ptr %_19, align 1
  %netmp = icmp ne i8 %load__17, %load__19
  store i1 %netmp, ptr %_16, align 1
  %load__16 = load i1, ptr %_16, align 1
  switch i1 %load__16, label %bb10 [
    i1 true, label %bb9
  ]

bb8:                                              ; preds = %bb6
  store i1 true, ptr %_0, align 1
  %ret_val13 = load i1, ptr %_0, align 1
  ret i1 %ret_val13

bb9:                                              ; preds = %bb7
  store i1 false, ptr %_0, align 1
  %ret_val14 = load i1, ptr %_0, align 1
  ret i1 %ret_val14

bb10:                                             ; preds = %bb7
  br label %bb11

bb11:                                             ; preds = %bb10
  %load__1215 = load i64, ptr %i, align 8
  %addtmp16 = add i64 %load__1215, 1
  store i64 %addtmp16, ptr %i, align 8
  br label %bb6
}

define i1 @str_eq(ptr %0, ptr %1) {
bb0:
  %_0 = alloca i1, align 1
  %a = alloca ptr, align 8
  %b = alloca ptr, align 8
  %_4 = alloca i1, align 1
  %_5 = alloca i1, align 1
  %_6 = alloca i64, align 8
  %_7 = alloca i1, align 1
  %_8 = alloca i64, align 8
  %_10 = alloca i1, align 1
  %_11 = alloca i1, align 1
  %_12 = alloca i64, align 8
  %_13 = alloca i1, align 1
  %_14 = alloca i64, align 8
  %pa = alloca ptr, align 8
  %pb = alloca ptr, align 8
  %i = alloca i64, align 8
  %_19 = alloca i1, align 1
  %_20 = alloca i1, align 1
  %_21 = alloca i8, align 1
  %_22 = alloca i1, align 1
  %_23 = alloca i8, align 1
  %_25 = alloca i1, align 1
  %_26 = alloca i8, align 1
  %_27 = alloca i8, align 1
  %_28 = alloca i8, align 1
  %_29 = alloca i8, align 1
  store ptr %0, ptr %a, align 8
  store ptr %1, ptr %b, align 8
  %load__1 = load ptr, ptr %a, align 8
  %ptr2int = ptrtoint ptr %load__1 to i64
  store i64 %ptr2int, ptr %_6, align 8
  %load__6 = load i64, ptr %_6, align 8
  %eqtmp = icmp eq i64 %load__6, 0
  store i1 %eqtmp, ptr %_5, align 1
  %load__2 = load ptr, ptr %b, align 8
  %ptr2int1 = ptrtoint ptr %load__2 to i64
  store i64 %ptr2int1, ptr %_8, align 8
  %load__8 = load i64, ptr %_8, align 8
  %eqtmp2 = icmp eq i64 %load__8, 0
  store i1 %eqtmp2, ptr %_7, align 1
  %load__5 = load i1, ptr %_5, align 1
  %load__7 = load i1, ptr %_7, align 1
  %andtmp = and i1 %load__5, %load__7
  store i1 %andtmp, ptr %_4, align 1
  %load__4 = load i1, ptr %_4, align 1
  switch i1 %load__4, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  store i1 true, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb2
  %load__13 = load ptr, ptr %a, align 8
  %ptr2int4 = ptrtoint ptr %load__13 to i64
  store i64 %ptr2int4, ptr %_12, align 8
  %load__12 = load i64, ptr %_12, align 8
  %eqtmp5 = icmp eq i64 %load__12, 0
  store i1 %eqtmp5, ptr %_11, align 1
  %load__26 = load ptr, ptr %b, align 8
  %ptr2int7 = ptrtoint ptr %load__26 to i64
  store i64 %ptr2int7, ptr %_14, align 8
  %load__14 = load i64, ptr %_14, align 8
  %eqtmp8 = icmp eq i64 %load__14, 0
  store i1 %eqtmp8, ptr %_13, align 1
  %load__11 = load i1, ptr %_11, align 1
  %load__139 = load i1, ptr %_13, align 1
  %ortmp = or i1 %load__11, %load__139
  store i1 %ortmp, ptr %_10, align 1
  %load__10 = load i1, ptr %_10, align 1
  switch i1 %load__10, label %bb5 [
    i1 true, label %bb4
  ]

bb4:                                              ; preds = %bb3
  store i1 false, ptr %_0, align 1
  %ret_val10 = load i1, ptr %_0, align 1
  ret i1 %ret_val10

bb5:                                              ; preds = %bb3
  br label %bb6

bb6:                                              ; preds = %bb5
  %load__111 = load ptr, ptr %a, align 8
  store ptr %load__111, ptr %pa, align 8
  %load__212 = load ptr, ptr %b, align 8
  store ptr %load__212, ptr %pb, align 8
  store i64 0, ptr %i, align 8
  br label %bb7

bb7:                                              ; preds = %bb12, %bb6
  %idx_load = load i64, ptr %i, align 8
  %raw_ptr_load = load ptr, ptr %pa, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__15[_17]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__15[_17]", ptr %_21, align 1
  %load__21 = load i8, ptr %_21, align 1
  %netmp = icmp ne i8 %load__21, 0
  store i1 %netmp, ptr %_20, align 1
  %idx_load13 = load i64, ptr %i, align 8
  %raw_ptr_load14 = load ptr, ptr %pb, align 8
  %ptr_idx15 = getelementptr i8, ptr %raw_ptr_load14, i64 %idx_load13
  %"load__16[_17]" = load i8, ptr %ptr_idx15, align 1
  store i8 %"load__16[_17]", ptr %_23, align 1
  %load__23 = load i8, ptr %_23, align 1
  %netmp16 = icmp ne i8 %load__23, 0
  store i1 %netmp16, ptr %_22, align 1
  %load__20 = load i1, ptr %_20, align 1
  %load__22 = load i1, ptr %_22, align 1
  %andtmp17 = and i1 %load__20, %load__22
  store i1 %andtmp17, ptr %_19, align 1
  %load__19 = load i1, ptr %_19, align 1
  switch i1 %load__19, label %bb9 [
    i1 true, label %bb8
  ]

bb8:                                              ; preds = %bb7
  %idx_load18 = load i64, ptr %i, align 8
  %raw_ptr_load19 = load ptr, ptr %pa, align 8
  %ptr_idx20 = getelementptr i8, ptr %raw_ptr_load19, i64 %idx_load18
  %"load__15[_17]21" = load i8, ptr %ptr_idx20, align 1
  store i8 %"load__15[_17]21", ptr %_26, align 1
  %idx_load22 = load i64, ptr %i, align 8
  %raw_ptr_load23 = load ptr, ptr %pb, align 8
  %ptr_idx24 = getelementptr i8, ptr %raw_ptr_load23, i64 %idx_load22
  %"load__16[_17]25" = load i8, ptr %ptr_idx24, align 1
  store i8 %"load__16[_17]25", ptr %_27, align 1
  %load__2626 = load i8, ptr %_26, align 1
  %load__27 = load i8, ptr %_27, align 1
  %netmp27 = icmp ne i8 %load__2626, %load__27
  store i1 %netmp27, ptr %_25, align 1
  %load__25 = load i1, ptr %_25, align 1
  switch i1 %load__25, label %bb11 [
    i1 true, label %bb10
  ]

bb9:                                              ; preds = %bb7
  %idx_load28 = load i64, ptr %i, align 8
  %raw_ptr_load29 = load ptr, ptr %pa, align 8
  %ptr_idx30 = getelementptr i8, ptr %raw_ptr_load29, i64 %idx_load28
  %"load__15[_17]31" = load i8, ptr %ptr_idx30, align 1
  store i8 %"load__15[_17]31", ptr %_28, align 1
  %idx_load32 = load i64, ptr %i, align 8
  %raw_ptr_load33 = load ptr, ptr %pb, align 8
  %ptr_idx34 = getelementptr i8, ptr %raw_ptr_load33, i64 %idx_load32
  %"load__16[_17]35" = load i8, ptr %ptr_idx34, align 1
  store i8 %"load__16[_17]35", ptr %_29, align 1
  %load__28 = load i8, ptr %_28, align 1
  %load__29 = load i8, ptr %_29, align 1
  %eqtmp36 = icmp eq i8 %load__28, %load__29
  store i1 %eqtmp36, ptr %_0, align 1
  %ret_val37 = load i1, ptr %_0, align 1
  ret i1 %ret_val37

bb10:                                             ; preds = %bb8
  store i1 false, ptr %_0, align 1
  %ret_val38 = load i1, ptr %_0, align 1
  ret i1 %ret_val38

bb11:                                             ; preds = %bb8
  br label %bb12

bb12:                                             ; preds = %bb11
  %load__17 = load i64, ptr %i, align 8
  %addtmp = add i64 %load__17, 1
  store i64 %addtmp, ptr %i, align 8
  br label %bb7
}

define i64 @str_len(ptr %0) {
bb0:
  %_0 = alloca i64, align 8
  %s = alloca ptr, align 8
  %_3 = alloca i1, align 1
  %_4 = alloca i64, align 8
  %p = alloca ptr, align 8
  %i = alloca i64, align 8
  %_8 = alloca i1, align 1
  %_9 = alloca i8, align 1
  store ptr %0, ptr %s, align 8
  %load__1 = load ptr, ptr %s, align 8
  %ptr2int = ptrtoint ptr %load__1 to i64
  store i64 %ptr2int, ptr %_4, align 8
  %load__4 = load i64, ptr %_4, align 8
  %eqtmp = icmp eq i64 %load__4, 0
  store i1 %eqtmp, ptr %_3, align 1
  %load__3 = load i1, ptr %_3, align 1
  switch i1 %load__3, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  store i64 0, ptr %_0, align 8
  %ret_val = load i64, ptr %_0, align 8
  ret i64 %ret_val

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb2
  %load__11 = load ptr, ptr %s, align 8
  store ptr %load__11, ptr %p, align 8
  store i64 0, ptr %i, align 8
  br label %bb4

bb4:                                              ; preds = %bb5, %bb3
  %idx_load = load i64, ptr %i, align 8
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__5[_6]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__5[_6]", ptr %_9, align 1
  %load__9 = load i8, ptr %_9, align 1
  %netmp = icmp ne i8 %load__9, 0
  store i1 %netmp, ptr %_8, align 1
  %load__8 = load i1, ptr %_8, align 1
  switch i1 %load__8, label %bb6 [
    i1 true, label %bb5
  ]

bb5:                                              ; preds = %bb4
  %load__6 = load i64, ptr %i, align 8
  %addtmp = add i64 %load__6, 1
  store i64 %addtmp, ptr %i, align 8
  br label %bb4

bb6:                                              ; preds = %bb4
  %load__62 = load i64, ptr %i, align 8
  store i64 %load__62, ptr %_0, align 8
  %ret_val3 = load i64, ptr %_0, align 8
  ret i64 %ret_val3
}

define i1 @str_starts_with(ptr %0, ptr %1) {
bb0:
  %_0 = alloca i1, align 1
  %s = alloca ptr, align 8
  %prefix = alloca ptr, align 8
  %_4 = alloca i1, align 1
  %_5 = alloca i1, align 1
  %_6 = alloca i64, align 8
  %_7 = alloca i1, align 1
  %_8 = alloca i64, align 8
  %ps = alloca ptr, align 8
  %pp = alloca ptr, align 8
  %i = alloca i64, align 8
  %_13 = alloca i1, align 1
  %_14 = alloca i8, align 1
  %_16 = alloca i1, align 1
  %_17 = alloca i1, align 1
  %_18 = alloca i8, align 1
  %_19 = alloca i1, align 1
  %_20 = alloca i8, align 1
  %_21 = alloca i8, align 1
  store ptr %0, ptr %s, align 8
  store ptr %1, ptr %prefix, align 8
  %load__1 = load ptr, ptr %s, align 8
  %ptr2int = ptrtoint ptr %load__1 to i64
  store i64 %ptr2int, ptr %_6, align 8
  %load__6 = load i64, ptr %_6, align 8
  %eqtmp = icmp eq i64 %load__6, 0
  store i1 %eqtmp, ptr %_5, align 1
  %load__2 = load ptr, ptr %prefix, align 8
  %ptr2int1 = ptrtoint ptr %load__2 to i64
  store i64 %ptr2int1, ptr %_8, align 8
  %load__8 = load i64, ptr %_8, align 8
  %eqtmp2 = icmp eq i64 %load__8, 0
  store i1 %eqtmp2, ptr %_7, align 1
  %load__5 = load i1, ptr %_5, align 1
  %load__7 = load i1, ptr %_7, align 1
  %ortmp = or i1 %load__5, %load__7
  store i1 %ortmp, ptr %_4, align 1
  %load__4 = load i1, ptr %_4, align 1
  switch i1 %load__4, label %bb2 [
    i1 true, label %bb1
  ]

bb1:                                              ; preds = %bb0
  store i1 false, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val

bb2:                                              ; preds = %bb0
  br label %bb3

bb3:                                              ; preds = %bb2
  %load__13 = load ptr, ptr %s, align 8
  store ptr %load__13, ptr %ps, align 8
  %load__24 = load ptr, ptr %prefix, align 8
  store ptr %load__24, ptr %pp, align 8
  store i64 0, ptr %i, align 8
  br label %bb4

bb4:                                              ; preds = %bb9, %bb3
  %idx_load = load i64, ptr %i, align 8
  %raw_ptr_load = load ptr, ptr %pp, align 8
  %ptr_idx = getelementptr i8, ptr %raw_ptr_load, i64 %idx_load
  %"load__10[_11]" = load i8, ptr %ptr_idx, align 1
  store i8 %"load__10[_11]", ptr %_14, align 1
  %load__14 = load i8, ptr %_14, align 1
  %netmp = icmp ne i8 %load__14, 0
  store i1 %netmp, ptr %_13, align 1
  %load__135 = load i1, ptr %_13, align 1
  switch i1 %load__135, label %bb6 [
    i1 true, label %bb5
  ]

bb5:                                              ; preds = %bb4
  %idx_load6 = load i64, ptr %i, align 8
  %raw_ptr_load7 = load ptr, ptr %ps, align 8
  %ptr_idx8 = getelementptr i8, ptr %raw_ptr_load7, i64 %idx_load6
  %"load__9[_11]" = load i8, ptr %ptr_idx8, align 1
  store i8 %"load__9[_11]", ptr %_18, align 1
  %load__18 = load i8, ptr %_18, align 1
  %eqtmp9 = icmp eq i8 %load__18, 0
  store i1 %eqtmp9, ptr %_17, align 1
  %idx_load10 = load i64, ptr %i, align 8
  %raw_ptr_load11 = load ptr, ptr %ps, align 8
  %ptr_idx12 = getelementptr i8, ptr %raw_ptr_load11, i64 %idx_load10
  %"load__9[_11]13" = load i8, ptr %ptr_idx12, align 1
  store i8 %"load__9[_11]13", ptr %_20, align 1
  %idx_load14 = load i64, ptr %i, align 8
  %raw_ptr_load15 = load ptr, ptr %pp, align 8
  %ptr_idx16 = getelementptr i8, ptr %raw_ptr_load15, i64 %idx_load14
  %"load__10[_11]17" = load i8, ptr %ptr_idx16, align 1
  store i8 %"load__10[_11]17", ptr %_21, align 1
  %load__20 = load i8, ptr %_20, align 1
  %load__21 = load i8, ptr %_21, align 1
  %netmp18 = icmp ne i8 %load__20, %load__21
  store i1 %netmp18, ptr %_19, align 1
  %load__17 = load i1, ptr %_17, align 1
  %load__19 = load i1, ptr %_19, align 1
  %ortmp19 = or i1 %load__17, %load__19
  store i1 %ortmp19, ptr %_16, align 1
  %load__16 = load i1, ptr %_16, align 1
  switch i1 %load__16, label %bb8 [
    i1 true, label %bb7
  ]

bb6:                                              ; preds = %bb4
  store i1 true, ptr %_0, align 1
  %ret_val20 = load i1, ptr %_0, align 1
  ret i1 %ret_val20

bb7:                                              ; preds = %bb5
  store i1 false, ptr %_0, align 1
  %ret_val21 = load i1, ptr %_0, align 1
  ret i1 %ret_val21

bb8:                                              ; preds = %bb5
  br label %bb9

bb9:                                              ; preds = %bb8
  %load__11 = load i64, ptr %i, align 8
  %addtmp = add i64 %load__11, 1
  store i64 %addtmp, ptr %i, align 8
  br label %bb4
}

define i32 @thread_sleep_ms(i32 %0) {
bb0:
  %_0 = alloca i32, align 4
  %ms = alloca i32, align 4
  %_2 = alloca i64, align 8
  store i32 %0, ptr %ms, align 4
  %load__1 = load i32, ptr %ms, align 4
  %casttmp = sext i32 %load__1 to i64
  store i64 %casttmp, ptr %_2, align 8
  %load__2 = load i64, ptr %_2, align 8
  %calltmp = call i32 @sleep_ms(i64 %load__2)
  store i32 %calltmp, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

define { i64 } @thread_spawn(ptr %0, ptr %1) {
bb0:
  %_0 = alloca { i64 }, align 8
  %func = alloca ptr, align 8
  %arg = alloca ptr, align 8
  %tid_buf = alloca ptr, align 8
  %null_attr = alloca ptr, align 8
  %res = alloca i32, align 4
  %_6 = alloca ptr, align 8
  %p = alloca ptr, align 8
  %tid = alloca i64, align 8
  %_9 = alloca i32, align 4
  store ptr %0, ptr %func, align 8
  store ptr %1, ptr %arg, align 8
  %calltmp = call ptr @malloc(i64 8)
  store ptr %calltmp, ptr %tid_buf, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  store ptr null, ptr %null_attr, align 8
  %load__3 = load ptr, ptr %tid_buf, align 8
  store ptr %load__3, ptr %_6, align 8
  %load__6 = load ptr, ptr %_6, align 8
  %load__4 = load ptr, ptr %null_attr, align 8
  %load__1 = load ptr, ptr %func, align 8
  %load__2 = load ptr, ptr %arg, align 8
  %calltmp1 = call i32 @pthread_create(ptr %load__6, ptr %load__4, ptr %load__1, ptr %load__2)
  store i32 %calltmp1, ptr %res, align 4
  br label %bb2

bb2:                                              ; preds = %bb1
  %load__32 = load ptr, ptr %tid_buf, align 8
  store ptr %load__32, ptr %p, align 8
  store i32 0, ptr %_9, align 4
  %idx_load = load i32, ptr %_9, align 4
  %idx_ext = sext i32 %idx_load to i64
  %raw_ptr_load = load ptr, ptr %p, align 8
  %ptr_idx = getelementptr i64, ptr %raw_ptr_load, i64 %idx_ext
  %"load__7[_9]" = load i64, ptr %ptr_idx, align 8
  store i64 %"load__7[_9]", ptr %tid, align 8
  %load__33 = load ptr, ptr %tid_buf, align 8
  call void @free(ptr %load__33)
  br label %bb3

bb3:                                              ; preds = %bb2
  %load__8 = load i64, ptr %tid, align 8
  %f_gep_0 = getelementptr inbounds nuw { i64 }, ptr %_0, i32 0, i32 0
  store i64 %load__8, ptr %f_gep_0, align 8
  %ret_val = load { i64 }, ptr %_0, align 8
  ret { i64 } %ret_val
}

define i32 @thread_yield() {
bb0:
  %_0 = alloca i32, align 4
  %calltmp = call i32 @sched_yield()
  store i32 %calltmp, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}

define i1 @write_file(ptr %0, ptr %1) {
bb0:
  %_0 = alloca i1, align 1
  %path = alloca ptr, align 8
  %contents = alloca ptr, align 8
  %f_opt = alloca { i32, { ptr, i1 } }, align 8
  %_4 = alloca i32, align 4
  %f = alloca { ptr, i1 }, align 8
  %file = alloca { ptr, i1 }, align 8
  %ok = alloca i1, align 1
  %_9 = alloca i32, align 4
  store ptr %0, ptr %path, align 8
  store ptr %1, ptr %contents, align 8
  %load__1 = load ptr, ptr %path, align 8
  %calltmp = call { i32, { ptr, i1 } } @File__create(ptr %load__1)
  store { i32, { ptr, i1 } } %calltmp, ptr %f_opt, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  br label %bb3

bb2:                                              ; preds = %bb12, %bb11, %bb10
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val

bb3:                                              ; preds = %bb1
  %tag_gep = getelementptr inbounds nuw { i32, { ptr, i1 } }, ptr %f_opt, i32 0, i32 0
  %tag_val = load i32, ptr %tag_gep, align 4
  store i32 %tag_val, ptr %_4, align 4
  %load__4 = load i32, ptr %_4, align 4
  switch i32 %load__4, label %bb4 [
    i32 1, label %bb8
  ]

bb4:                                              ; preds = %bb3
  %tag_gep1 = getelementptr inbounds nuw { i32, { ptr, i1 } }, ptr %f_opt, i32 0, i32 0
  %tag_val2 = load i32, ptr %tag_gep1, align 4
  store i32 %tag_val2, ptr %_9, align 4
  %load__9 = load i32, ptr %_9, align 4
  switch i32 %load__9, label %bb5 [
    i32 0, label %bb11
  ]

bb5:                                              ; preds = %bb4
  br label %bb12

bb6:                                              ; No predecessors!
  unreachable

bb7:                                              ; preds = %bb8
  %load__5 = load { ptr, i1 }, ptr %f, align 8
  store { ptr, i1 } %load__5, ptr %file, align 8
  %load__2 = load ptr, ptr %contents, align 8
  %calltmp3 = call i1 @File__write_str(ptr %file, ptr %load__2)
  store i1 %calltmp3, ptr %ok, align 1
  br label %bb9

bb8:                                              ; preds = %bb3
  %enum_f_0 = getelementptr inbounds nuw { i32, { ptr, i1 } }, ptr %f_opt, i32 0, i32 1
  %load__3.0 = load { ptr, i1 }, ptr %enum_f_0, align 8
  store { ptr, i1 } %load__3.0, ptr %f, align 8
  br label %bb7

bb9:                                              ; preds = %bb7
  call void @File__close(ptr %file)
  br label %bb10

bb10:                                             ; preds = %bb9
  %load__7 = load i1, ptr %ok, align 1
  store i1 %load__7, ptr %_0, align 1
  br label %bb2

bb11:                                             ; preds = %bb4
  store i1 false, ptr %_0, align 1
  br label %bb2

bb12:                                             ; preds = %bb5
  store i1 false, ptr %_0, align 1
  br label %bb2
}

define i1 @write_file_string(ptr %0, { { ptr, i64, i64 } } %1) {
bb0:
  %_0 = alloca i1, align 1
  %path = alloca ptr, align 8
  %content = alloca { { ptr, i64, i64 } }, align 8
  %fp = alloca ptr, align 8
  %_5 = alloca i1, align 1
  %_6 = alloca i64, align 8
  %p = alloca ptr, align 8
  %_8 = alloca ptr, align 8
  %len = alloca i64, align 8
  %_10 = alloca ptr, align 8
  %_11 = alloca ptr, align 8
  %_12 = alloca i64, align 8
  %_13 = alloca i32, align 4
  store ptr %0, ptr %path, align 8
  store { { ptr, i64, i64 } } %1, ptr %content, align 8
  %load__1 = load ptr, ptr %path, align 8
  %calltmp = call ptr @fopen(ptr %load__1, ptr @str_lit.7)
  store ptr %calltmp, ptr %fp, align 8
  br label %bb1

bb1:                                              ; preds = %bb0
  %load__3 = load ptr, ptr %fp, align 8
  %ptr2int = ptrtoint ptr %load__3 to i64
  store i64 %ptr2int, ptr %_6, align 8
  %load__6 = load i64, ptr %_6, align 8
  %eqtmp = icmp eq i64 %load__6, 0
  store i1 %eqtmp, ptr %_5, align 1
  %load__5 = load i1, ptr %_5, align 1
  switch i1 %load__5, label %bb3 [
    i1 true, label %bb2
  ]

bb2:                                              ; preds = %bb1
  store i1 false, ptr %_0, align 1
  %ret_val = load i1, ptr %_0, align 1
  ret i1 %ret_val

bb3:                                              ; preds = %bb1
  br label %bb4

bb4:                                              ; preds = %bb3
  %load__2 = load { { ptr, i64, i64 } }, ptr %content, align 8
  %calltmp1 = call ptr @String__as_ptr({ { ptr, i64, i64 } } %load__2)
  store ptr %calltmp1, ptr %_8, align 8
  br label %bb5

bb5:                                              ; preds = %bb4
  %load__8 = load ptr, ptr %_8, align 8
  store ptr %load__8, ptr %p, align 8
  %load__22 = load { { ptr, i64, i64 } }, ptr %content, align 8
  %calltmp3 = call ptr @String__as_ptr({ { ptr, i64, i64 } } %load__22)
  store ptr %calltmp3, ptr %_11, align 8
  br label %bb6

bb6:                                              ; preds = %bb5
  %load__11 = load ptr, ptr %_11, align 8
  store ptr %load__11, ptr %_10, align 8
  %load__10 = load ptr, ptr %_10, align 8
  %calltmp4 = call i64 @str_len(ptr %load__10)
  store i64 %calltmp4, ptr %len, align 8
  br label %bb7

bb7:                                              ; preds = %bb6
  %load__7 = load ptr, ptr %p, align 8
  %load__9 = load i64, ptr %len, align 8
  %load__35 = load ptr, ptr %fp, align 8
  %calltmp6 = call i64 @fwrite(ptr %load__7, i64 1, i64 %load__9, ptr %load__35)
  store i64 %calltmp6, ptr %_12, align 8
  br label %bb8

bb8:                                              ; preds = %bb7
  %load__37 = load ptr, ptr %fp, align 8
  %calltmp8 = call i32 @fclose(ptr %load__37)
  store i32 %calltmp8, ptr %_13, align 4
  br label %bb9

bb9:                                              ; preds = %bb8
  store i1 true, ptr %_0, align 1
  %ret_val9 = load i1, ptr %_0, align 1
  ret i1 %ret_val9
}

define i32 @yield_now() {
bb0:
  %_0 = alloca i32, align 4
  %calltmp = call i32 @sched_yield()
  store i32 %calltmp, ptr %_0, align 4
  br label %bb1

bb1:                                              ; preds = %bb0
  %ret_val = load i32, ptr %_0, align 4
  ret i32 %ret_val
}
