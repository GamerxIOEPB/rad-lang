; ModuleID = 'radc_compiled'
source_filename = "rad"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare ptr @malloc(i64)
declare void @free(ptr)
declare ptr @realloc(ptr, i64)
declare i32 @system(ptr)
declare i32 @puts(ptr)
declare i32 @printf(ptr, ...)
declare ptr @fopen(ptr, ptr)
declare i32 @fclose(ptr)
declare i64 @fread(ptr, i64, i64, ptr)
declare i64 @fwrite(ptr, i64, i64, ptr)
declare i32 @fseek(ptr, i64, i32)
declare i64 @ftell(ptr)
declare ptr @getenv(ptr)

@.empty_str = private unnamed_addr constant [1 x i8] c"\00", align 1

define ptr @new() {
entry:
  %obj = call ptr @malloc(i64 24)
  %buf = call ptr @malloc(i64 512)
  store i8 0, ptr %buf, align 1
  store ptr %buf, ptr %obj, align 8
  %cap_ptr = getelementptr inbounds i8, ptr %obj, i64 8
  store i64 64, ptr %cap_ptr, align 8
  %len_ptr = getelementptr inbounds i8, ptr %obj, i64 16
  store i64 0, ptr %len_ptr, align 8
  ret ptr %obj
}

define ptr @as_ptr(ptr %obj) {
entry:
  %is_null = icmp eq ptr %obj, null
  br i1 %is_null, label %ret_empty, label %load_buf
ret_empty:
  ret ptr @.empty_str
load_buf:
  %buf = load ptr, ptr %obj, align 8
  %buf_is_null = icmp eq ptr %buf, null
  br i1 %buf_is_null, label %ret_empty, label %ret_buf
ret_buf:
  ret ptr %buf
}

define i64 @len(ptr %obj) {
entry:
  %is_null = icmp eq ptr %obj, null
  br i1 %is_null, label %ret_zero, label %load_len
ret_zero:
  ret i64 0
load_len:
  %len_ptr = getelementptr inbounds i8, ptr %obj, i64 16
  %len = load i64, ptr %len_ptr, align 8
  ret i64 %len
}

define void @push_byte(ptr %obj, i64 %b) {
entry:
  %is_null = icmp eq ptr %obj, null
  br i1 %is_null, label %exit, label %do_push
do_push:
  %buf_slot = getelementptr inbounds i8, ptr %obj, i64 0
  %cap_slot = getelementptr inbounds i8, ptr %obj, i64 8
  %len_slot = getelementptr inbounds i8, ptr %obj, i64 16
  %buf = load ptr, ptr %buf_slot, align 8
  %cap = load i64, ptr %cap_slot, align 8
  %len = load i64, ptr %len_slot, align 8
  %len_p2 = add i64 %len, 2
  %needs_grow = icmp uge i64 %len_p2, %cap
  br i1 %needs_grow, label %grow, label %write_byte
grow:
  %new_cap = shl i64 %cap, 1
  %adj_cap_cond = icmp ult i64 %new_cap, 512
  %adj_cap = select i1 %adj_cap_cond, i64 512, i64 %new_cap
  %new_buf = call ptr @realloc(ptr %buf, i64 %adj_cap)
  store ptr %new_buf, ptr %buf_slot, align 8
  store i64 %adj_cap, ptr %cap_slot, align 8
  br label %write_byte
write_byte:
  %cur_buf = phi ptr [ %buf, %do_push ], [ %new_buf, %grow ]
  %byte_i8 = trunc i64 %b to i8
  %b_ptr = getelementptr inbounds i8, ptr %cur_buf, i64 %len
  store i8 %byte_i8, ptr %b_ptr, align 1
  %new_len = add i64 %len, 1
  %term_ptr = getelementptr inbounds i8, ptr %cur_buf, i64 %new_len
  store i8 0, ptr %term_ptr, align 1
  store i64 %new_len, ptr %len_slot, align 8
  br label %exit
exit:
  ret void
}

define void @push(ptr %obj, i64 %item) {
entry:
  %is_null = icmp eq ptr %obj, null
  br i1 %is_null, label %exit, label %do_push
do_push:
  %buf_slot = getelementptr inbounds i8, ptr %obj, i64 0
  %cap_slot = getelementptr inbounds i8, ptr %obj, i64 8
  %len_slot = getelementptr inbounds i8, ptr %obj, i64 16
  %buf = load ptr, ptr %buf_slot, align 8
  %cap = load i64, ptr %cap_slot, align 8
  %len = load i64, ptr %len_slot, align 8
  %needs_grow = icmp uge i64 %len, %cap
  br i1 %needs_grow, label %grow, label %write_item
grow:
  %new_cap = shl i64 %cap, 1
  %adj_cap_cond = icmp ult i64 %new_cap, 64
  %adj_cap = select i1 %adj_cap_cond, i64 64, i64 %new_cap
  %bytes = shl i64 %adj_cap, 3
  %new_buf = call ptr @realloc(ptr %buf, i64 %bytes)
  store ptr %new_buf, ptr %buf_slot, align 8
  store i64 %adj_cap, ptr %cap_slot, align 8
  br label %write_item
write_item:
  %cur_buf = phi ptr [ %buf, %do_push ], [ %new_buf, %grow ]
  %slot = getelementptr inbounds i64, ptr %cur_buf, i64 %len
  store i64 %item, ptr %slot, align 8
  %new_len = add i64 %len, 1
  store i64 %new_len, ptr %len_slot, align 8
  br label %exit
exit:
  ret void
}

define i64 @pop(ptr %obj) {
entry:
  %is_null = icmp eq ptr %obj, null
  br i1 %is_null, label %exit_zero, label %do_pop
do_pop:
  %len_slot = getelementptr inbounds i8, ptr %obj, i64 16
  %len = load i64, ptr %len_slot, align 8
  %is_empty = icmp eq i64 %len, 0
  br i1 %is_empty, label %exit_zero, label %do_dec
do_dec:
  %new_len = sub i64 %len, 1
  store i64 %new_len, ptr %len_slot, align 8
  %buf_slot = getelementptr inbounds i8, ptr %obj, i64 0
  %buf = load ptr, ptr %buf_slot, align 8
  %slot = getelementptr inbounds i64, ptr %buf, i64 %new_len
  %val = load i64, ptr %slot, align 8
  ret i64 %val
exit_zero:
  ret i64 0
}

define void @push_str(ptr %obj, ptr %src) {
entry:
  %is_null = icmp eq ptr %src, null
  br i1 %is_null, label %exit, label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next_i, %body ]
  %char_ptr = getelementptr inbounds i8, ptr %src, i64 %i
  %ch = load i8, ptr %char_ptr, align 1
  %is_end = icmp eq i8 %ch, 0
  br i1 %is_end, label %exit, label %body
body:
  %ch_i64 = zext i8 %ch to i64
  call void @push_byte(ptr %obj, i64 %ch_i64)
  %next_i = add i64 %i, 1
  br label %loop
exit:
  ret void
}

define ptr @from_str(ptr %src) {
entry:
  %s = call ptr @new()
  call void @push_str(ptr %s, ptr %src)
  ret ptr %s
}

@.str.0 = private unnamed_addr constant [4 x i8] c"pos\00", align 1
@.str.1 = private unnamed_addr constant [4 x i8] c"neg\00", align 1
@.str.2 = private unnamed_addr constant [5 x i8] c"zero\00", align 1
@.str.3 = private unnamed_addr constant [10 x i8] c"%s %s %s\0A\00", align 1

define ptr @classify(i32 %n) {
entry:
  %n.addr = alloca i32, align 8
  store i32 %n, ptr %n.addr, align 8
  %1 = load i64, ptr %n.addr, align 8
  %2 = add i64 0, 0
  %3 = icmp sgt i64 %1, %2
  %4 = zext i1 %3 to i64
  %5 = icmp ne i64 %4, 0
  br i1 %5, label %if.then.0, label %if.else.1
if.then.0:
  %6 = getelementptr inbounds [4 x i8], ptr @.str.0, i32 0, i32 0
  ret ptr %6
if.else.1:
  br label %if.merge.2
if.merge.2:
  %7 = load i64, ptr %n.addr, align 8
  %8 = add i64 0, 0
  %9 = icmp slt i64 %7, %8
  %10 = zext i1 %9 to i64
  %11 = icmp ne i64 %10, 0
  br i1 %11, label %if.then.3, label %if.else.4
if.then.3:
  %12 = getelementptr inbounds [4 x i8], ptr @.str.1, i32 0, i32 0
  ret ptr %12
if.else.4:
  br label %if.merge.5
if.merge.5:
  %13 = getelementptr inbounds [5 x i8], ptr @.str.2, i32 0, i32 0
  ret ptr %13
}

define i32 @main(i32 %argc, ptr %argv) {
entry:
  %argc.addr = alloca i32, align 4
  store i32 %argc, ptr %argc.addr, align 4
  %argv.addr = alloca ptr, align 8
  store ptr %argv, ptr %argv.addr, align 8
  %p.addr = alloca i64, align 8
  %n.addr = alloca i64, align 8
  %z.addr = alloca i64, align 8
  %14 = add i64 0, 5
  %15 = trunc i64 %14 to i32
  %16 = call ptr @classify(i32 %15)
  %17 = ptrtoint ptr %16 to i64
  store i64 %17, ptr %p.addr, align 8
  %18 = add i64 0, 3
  %19 = sub nsw i64 0, %18
  %20 = trunc i64 %19 to i32
  %21 = call ptr @classify(i32 %20)
  %22 = ptrtoint ptr %21 to i64
  store i64 %22, ptr %n.addr, align 8
  %23 = add i64 0, 0
  %24 = trunc i64 %23 to i32
  %25 = call ptr @classify(i32 %24)
  %26 = ptrtoint ptr %25 to i64
  store i64 %26, ptr %z.addr, align 8
  %27 = getelementptr inbounds [10 x i8], ptr @.str.3, i32 0, i32 0
  %28 = ptrtoint ptr %27 to i64
  %29 = load i64, ptr %p.addr, align 8
  %30 = load i64, ptr %n.addr, align 8
  %31 = load i64, ptr %z.addr, align 8
  %32 = call i64 @printf(i64 %28, i64 %29, i64 %30, i64 %31)
  ret i32 0
}

