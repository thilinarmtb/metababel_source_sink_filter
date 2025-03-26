#include <stdio.h>

#include <mpi.h>
#include <thapi.h>

int main(int argc, char *argv[]) {
  MPI_Init(&argc, &argv);

  thapi_start();
  MPI_Finalize();
  thapi_stop();
  thapi_stop();

  return 0;
}
