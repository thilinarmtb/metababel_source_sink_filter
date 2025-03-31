#include <metababel/metababel.h>
#include <stdio.h>

void btx_start_callbacks(
    void *btx_handle,
    void *usr_data,
    long int cpuid,
    int vpid, int vtid) {

   printf("Received btx_start_callbacks message\n");
}

void btx_stop_callbacks(
    void *btx_handle,
    void *usr_data,
    long int cpuid,
    int vpid, int vtid) {

   printf("Received btx_stop_callbacks message\n");
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_lttng_ust_toggle_start(btx_handle, &btx_start_callbacks);
  btx_register_callbacks_lttng_ust_toggle_stop(btx_handle, &btx_stop_callbacks);
}
