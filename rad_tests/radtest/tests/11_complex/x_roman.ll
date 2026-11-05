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

@.str.0 = private unnamed_addr constant [10 x i8] c"value=%d\0A\00", align 1
@.str.1 = private unnamed_addr constant [8 x i8] c"iii=%d\0A\00", align 1

define i32 @letter_value(i32 %code) {
entry:
  %code.addr = alloca i32, align 8
  store i32 %code, ptr %code.addr, align 8
  %1 = load i32, ptr %code.addr, align 8
  %2 = sext i32 %1 to i64
  %3 = add i64 0, 73
  %4 = icmp eq i64 %2, %3
  %5 = zext i1 %4 to i64
  %6 = icmp ne i64 %5, 0
  br i1 %6, label %if.then.0, label %if.else.1
if.then.0:
  %7 = add i64 0, 1
  %8 = trunc i64 %7 to i32
  ret i32 %8
if.else.1:
  br label %if.merge.2
if.merge.2:
  %9 = load i32, ptr %code.addr, align 8
  %10 = sext i32 %9 to i64
  %11 = add i64 0, 86
  %12 = icmp eq i64 %10, %11
  %13 = zext i1 %12 to i64
  %14 = icmp ne i64 %13, 0
  br i1 %14, label %if.then.3, label %if.else.4
if.then.3:
  %15 = add i64 0, 5
  %16 = trunc i64 %15 to i32
  ret i32 %16
if.else.4:
  br label %if.merge.5
if.merge.5:
  %17 = load i32, ptr %code.addr, align 8
  %18 = sext i32 %17 to i64
  %19 = add i64 0, 88
  %20 = icmp eq i64 %18, %19
  %21 = zext i1 %20 to i64
  %22 = icmp ne i64 %21, 0
  br i1 %22, label %if.then.6, label %if.else.7
if.then.6:
  %23 = add i64 0, 10
  %24 = trunc i64 %23 to i32
  ret i32 %24
if.else.7:
  br label %if.merge.8
if.merge.8:
  %25 = load i32, ptr %code.addr, align 8
  %26 = sext i32 %25 to i64
  %27 = add i64 0, 76
  %28 = icmp eq i64 %26, %27
  %29 = zext i1 %28 to i64
  %30 = icmp ne i64 %29, 0
  br i1 %30, label %if.then.9, label %if.else.10
if.then.9:
  %31 = add i64 0, 50
  %32 = trunc i64 %31 to i32
  ret i32 %32
if.else.10:
  br label %if.merge.11
if.merge.11:
  %33 = load i32, ptr %code.addr, align 8
  %34 = sext i32 %33 to i64
  %35 = add i64 0, 67
  %36 = icmp eq i64 %34, %35
  %37 = zext i1 %36 to i64
  %38 = icmp ne i64 %37, 0
  br i1 %38, label %if.then.12, label %if.else.13
if.then.12:
  %39 = add i64 0, 100
  %40 = trunc i64 %39 to i32
  ret i32 %40
if.else.13:
  br label %if.merge.14
if.merge.14:
  %41 = load i32, ptr %code.addr, align 8
  %42 = sext i32 %41 to i64
  %43 = add i64 0, 68
  %44 = icmp eq i64 %42, %43
  %45 = zext i1 %44 to i64
  %46 = icmp ne i64 %45, 0
  br i1 %46, label %if.then.15, label %if.else.16
if.then.15:
  %47 = add i64 0, 500
  %48 = trunc i64 %47 to i32
  ret i32 %48
if.else.16:
  br label %if.merge.17
if.merge.17:
  %49 = load i32, ptr %code.addr, align 8
  %50 = sext i32 %49 to i64
  %51 = add i64 0, 77
  %52 = icmp eq i64 %50, %51
  %53 = zext i1 %52 to i64
  %54 = icmp ne i64 %53, 0
  br i1 %54, label %if.then.18, label %if.else.19
if.then.18:
  %55 = add i64 0, 1000
  %56 = trunc i64 %55 to i32
  ret i32 %56
if.else.19:
  br label %if.merge.20
if.merge.20:
  %57 = add i64 0, 0
  %58 = trunc i64 %57 to i32
  ret i32 %58
}

define i32 @decode(ptr %p, i32 %n) {
entry:
  %p.addr = alloca ptr, align 8
  store ptr %p, ptr %p.addr, align 8
  %n.addr = alloca i32, align 8
  store i32 %n, ptr %n.addr, align 8
  %total.addr = alloca i64, align 8
  %i.addr = alloca i64, align 8
  %cur.addr = alloca i64, align 8
  %nxt.addr = alloca i64, align 8
  %59 = add i64 0, 0
  store i64 %59, ptr %total.addr, align 8
  %60 = add i64 0, 0
  store i64 %60, ptr %i.addr, align 8
  br label %while.cond.21
while.cond.21:
  %61 = load i64, ptr %i.addr, align 8
  %62 = load i64, ptr %n.addr, align 8
  %63 = icmp slt i64 %61, %62
  %64 = zext i1 %63 to i64
  %65 = icmp ne i64 %64, 0
  br i1 %65, label %while.body.22, label %while.end.23
while.body.22:
  %66 = load i64, ptr %p.addr, align 8
  %67 = inttoptr i64 %66 to ptr
  %68 = load i64, ptr %i.addr, align 8
  %69 = getelementptr inbounds i64, ptr %67, i64 %68
  %70 = load i64, ptr %69, align 8
  %71 = trunc i64 %70 to i32
  %72 = call i32 @letter_value(i32 %71)
  %73 = zext i32 %72 to i64
  store i64 %73, ptr %cur.addr, align 8
  %74 = load i64, ptr %i.addr, align 8
  %75 = add i64 0, 1
  %76 = add nsw i64 %74, %75
  %77 = load i64, ptr %n.addr, align 8
  %78 = icmp slt i64 %76, %77
  %79 = zext i1 %78 to i64
  %80 = icmp ne i64 %79, 0
  br i1 %80, label %if.then.24, label %if.else.25
if.then.24:
  %81 = load i64, ptr %p.addr, align 8
  %82 = inttoptr i64 %81 to ptr
  %83 = load i64, ptr %i.addr, align 8
  %84 = add i64 0, 1
  %85 = add nsw i64 %83, %84
  %86 = getelementptr inbounds i64, ptr %82, i64 %85
  %87 = load i64, ptr %86, align 8
  %88 = trunc i64 %87 to i32
  %89 = call i32 @letter_value(i32 %88)
  %90 = zext i32 %89 to i64
  store i64 %90, ptr %nxt.addr, align 8
  %91 = load i64, ptr %cur.addr, align 8
  %92 = load i64, ptr %nxt.addr, align 8
  %93 = icmp slt i64 %91, %92
  %94 = zext i1 %93 to i64
  %95 = icmp ne i64 %94, 0
  br i1 %95, label %if.then.27, label %if.else.28
if.then.27:
  %96 = load i64, ptr %total.addr, align 8
  %97 = load i64, ptr %cur.addr, align 8
  %98 = sub nsw i64 %96, %97
  store i64 %98, ptr %total.addr, align 8
  br label %if.merge.29
if.else.28:
  %99 = load i64, ptr %total.addr, align 8
  %100 = load i64, ptr %cur.addr, align 8
  %101 = add nsw i64 %99, %100
  store i64 %101, ptr %total.addr, align 8
  br label %if.merge.29
if.merge.29:
  br label %if.merge.26
if.else.25:
  %102 = load i64, ptr %total.addr, align 8
  %103 = load i64, ptr %cur.addr, align 8
  %104 = add nsw i64 %102, %103
  store i64 %104, ptr %total.addr, align 8
  br label %if.merge.26
if.merge.26:
  %105 = load i64, ptr %i.addr, align 8
  %106 = add i64 0, 1
  %107 = add nsw i64 %105, %106
  store i64 %107, ptr %i.addr, align 8
  br label %while.cond.21
while.end.23:
  %108 = load i64, ptr %total.addr, align 8
  %109 = trunc i64 %108 to i32
  ret i32 %109
}

define i32 @main(i32 %argc, ptr %argv) {
entry:
  %argc.addr = alloca i32, align 4
  store i32 %argc, ptr %argc.addr, align 4
  %argv.addr = alloca ptr, align 8
  store ptr %argv, ptr %argv.addr, align 8
  %letters.addr = alloca i64, align 8
  %p.addr = alloca i64, align 8
  %n.addr = alloca i64, align 8
  %value.addr = alloca i64, align 8
  %three.addr = alloca i64, align 8
  %p3.addr = alloca i64, align 8
  %v3.addr = alloca i64, align 8
  %110 = call ptr @new()
  %111 = ptrtoint ptr %110 to i64
  store i64 %111, ptr %letters.addr, align 8
  %112 = load i64, ptr %letters.addr, align 8
  %113 = inttoptr i64 %112 to ptr
  %114 = add i64 0, 77
  %115 = call i64 @push(ptr %113, i64 %114)
  %116 = load i64, ptr %letters.addr, align 8
  %117 = inttoptr i64 %116 to ptr
  %118 = add i64 0, 67
  %119 = call i64 @push(ptr %117, i64 %118)
  %120 = load i64, ptr %letters.addr, align 8
  %121 = inttoptr i64 %120 to ptr
  %122 = add i64 0, 77
  %123 = call i64 @push(ptr %121, i64 %122)
  %124 = load i64, ptr %letters.addr, align 8
  %125 = inttoptr i64 %124 to ptr
  %126 = add i64 0, 88
  %127 = call i64 @push(ptr %125, i64 %126)
  %128 = load i64, ptr %letters.addr, align 8
  %129 = inttoptr i64 %128 to ptr
  %130 = add i64 0, 67
  %131 = call i64 @push(ptr %129, i64 %130)
  %132 = load i64, ptr %letters.addr, align 8
  %133 = inttoptr i64 %132 to ptr
  %134 = add i64 0, 73
  %135 = call i64 @push(ptr %133, i64 %134)
  %136 = load i64, ptr %letters.addr, align 8
  %137 = inttoptr i64 %136 to ptr
  %138 = add i64 0, 86
  %139 = call i64 @push(ptr %137, i64 %138)
  %140 = load i64, ptr %letters.addr, align 8
  %141 = inttoptr i64 %140 to ptr
  %142 = load ptr, ptr %141, align 8
  %143 = ptrtoint ptr %142 to i64
  store i64 %143, ptr %p.addr, align 8
  %144 = load i64, ptr %letters.addr, align 8
  %145 = inttoptr i64 %144 to ptr
  %146 = getelementptr inbounds i64, ptr %145, i64 2
  %147 = load i64, ptr %146, align 8
  store i64 %147, ptr %n.addr, align 8
  %148 = load i64, ptr %p.addr, align 8
  %149 = inttoptr i64 %148 to ptr
  %150 = load i64, ptr %n.addr, align 8
  %151 = trunc i64 %150 to i32
  %152 = call i32 @decode(ptr %149, i32 %151)
  %153 = zext i32 %152 to i64
  store i64 %153, ptr %value.addr, align 8
  %154 = getelementptr inbounds [10 x i8], ptr @.str.0, i32 0, i32 0
  %155 = ptrtoint ptr %154 to i64
  %156 = load i64, ptr %value.addr, align 8
  %157 = call i64 @printf(i64 %155, i64 %156)
  %158 = call ptr @new()
  %159 = ptrtoint ptr %158 to i64
  store i64 %159, ptr %three.addr, align 8
  %160 = load i64, ptr %three.addr, align 8
  %161 = inttoptr i64 %160 to ptr
  %162 = add i64 0, 73
  %163 = call i64 @push(ptr %161, i64 %162)
  %164 = load i64, ptr %three.addr, align 8
  %165 = inttoptr i64 %164 to ptr
  %166 = add i64 0, 73
  %167 = call i64 @push(ptr %165, i64 %166)
  %168 = load i64, ptr %three.addr, align 8
  %169 = inttoptr i64 %168 to ptr
  %170 = add i64 0, 73
  %171 = call i64 @push(ptr %169, i64 %170)
  %172 = load i64, ptr %three.addr, align 8
  %173 = inttoptr i64 %172 to ptr
  %174 = load ptr, ptr %173, align 8
  %175 = ptrtoint ptr %174 to i64
  store i64 %175, ptr %p3.addr, align 8
  %176 = load i64, ptr %p3.addr, align 8
  %177 = inttoptr i64 %176 to ptr
  %178 = add i64 0, 3
  %179 = trunc i64 %178 to i32
  %180 = call i32 @decode(ptr %177, i32 %179)
  %181 = zext i32 %180 to i64
  store i64 %181, ptr %v3.addr, align 8
  %182 = getelementptr inbounds [8 x i8], ptr @.str.1, i32 0, i32 0
  %183 = ptrtoint ptr %182 to i64
  %184 = load i64, ptr %v3.addr, align 8
  %185 = call i64 @printf(i64 %183, i64 %184)
  ret i32 0
}

