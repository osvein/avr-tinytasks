struct task;

__attribute__((__noreturn__)) void task_terminate(void);

static inline void task_block(struct task *queue) {
	__asm__ volatile (
		"call task_block_"
		: "+z" (queue) :: "cc", "memory", "x", "r24", "r25"
	);
}

/* note that there is no memory barrier */
static inline struct task *task_unblock(struct task *queue) {
	struct task *task;

	__asm__ volatile (
		"call task_unblock_"
		: "+x" (queue), "=z" (task) :: "cc", "r24", "r25"
	);
	return task;
}
