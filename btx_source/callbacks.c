#include <metababel/metababel.h>

void btx_init_proc(void *btx_handle, void *usr_data) {
  btx_downstream_set_environment_dummy(btx_handle, "roger");
}

void btx_push_usr_messages(void *btx_handle, void *usr_data, btx_source_status_t *status) {
  int vpid = 1;
  int vtid= 1;
  btx_push_message_stop(btx_handle, vpid, vtid);
  btx_push_message_start(btx_handle, vpid, vtid);
  btx_push_message_stop(btx_handle, vpid, vtid);
  *status = BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_processing(btx_handle, btx_init_proc);
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}
