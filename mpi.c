#include <stdio.h>

#include <mpi.h>
#include <thapi.h>

int main(int argc, char *argv[]) {
  thapi_start();
  MPI_Init(&argc, &argv);
  MPI_Finalize();
  thapi_stop();

  return 0;
}
