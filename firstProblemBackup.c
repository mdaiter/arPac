#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<unistd.h>
#include <stddef.h>
#include <sys/types.h>
#include <sys/wait.h>

extern char **environ;

int getInput(char**** commHold, char* ibuf, int *arr){
	int i;
    size_t sz = 256;
    getline(&ibuf, &sz, stdin);
    ibuf[strlen(ibuf)-1] = '\0';
    i = strlen(ibuf);
   // ibuf = realloc(ibuf, i*sizeof(char));

    //printf("%s is ibuf %d %d\n", ibuf, (int)strlen(ibuf), (int)sizeof(ibuf) );
    int commHoldCount = 0;
    int arrPlaceHolder = 0;
    const char* constInBuf = ibuf;
    char* pch;
    pch = strsep(&constInBuf, ";");
    while(pch != NULL){
        printf("%s is the pch\n", pch);
        int countOfArr = 0;
        char* psh;
        int pStrCt = 0;
        char*** pStr = (char***)malloc(sizeof(char**));
        psh = strsep(&pch, "|");
        printf("%s is psh\n", psh);
        while (psh != NULL){
            char* pph;
            int str = 0;
            char** pS = (char**)malloc(sizeof(char*));
            printf("%s is psh\n", psh);

            pph = strsep(&psh, " ");
            printf("%s is pph\n", pph);
            while(pph != NULL){
                pS[str] = pph;
                str++;
                printf("Got a space\n");
                pS = (char**)realloc(pS, str * sizeof(char*));
                printf("%s is the new char*\n", pS[str - 1]);
                pph = strsep(&psh, " ");
                printf("%s is new pph\n", pph);
            }

            pStr[pStrCt] = pS;
            printf("%s is pStr\n", *pStr[pStrCt]);
            pStrCt++;
            pStr = realloc(pStr, pStrCt*sizeof(char**));
            psh = strsep(&pch, "|");
        }
        arr[arrPlaceHolder] = pStrCt;
        arrPlaceHolder++;
        arr = (int*)realloc(arr, arrPlaceHolder * sizeof(int));

        commHold[commHoldCount] = pStr;
        commHoldCount++;
        commHold = realloc(commHold, commHoldCount * sizeof(char***));
        pch = strsep (&constInBuf, ";");
    }
    return commHoldCount;
}

int main(int* argc, char** argv){
    char* ibuf;
    char**** commandHolder;
    int *pStrCt = (int*)malloc(sizeof(int));
    int commHoldCount = 0;
	while(1){
	    ibuf = (char*)malloc(256*sizeof(char));
       	 	/* allocate array of 10 pointers and initialize them all to 0*/
        	commandHolder = (char****)malloc(sizeof(char***));
        	commHoldCount = getInput(commandHolder, ibuf, pStrCt);
        	printf("%s is string", commandHolder[0][0][0]);
        	if (commandHolder[0][0][0] == NULL){
        	    continue;
        	}
        	if (strncmp(commandHolder[0][0][0], "exit", 4) == 0){
        	    break;
        	}

	        for (int i = 0; i < commHoldCount; i++){
	            fflush(stdout);
                int fd[pStrCt[i] - 2][2];
                for (int k = 0; k < pStrCt[i] - 2; k++){
                    if(pipe(fd[k])){
	                    perror("pipe");
	                }
                }

                pid_t pid[pStrCt[i] -1];

                for (int j = 0; j < pStrCt[i]; j++){

                pid[j] = fork();
                if (pid[j] == 0)
                {
                    if (j == 0){
                        dup2(fd[j][1], 1);
                    }
                    else if(j == pStrCt[i] - 1){
                        dup2(fd[j - 1][0], 0);
                    }
                    else{
                        dup2(fd[j-1][0], 0);
                        dup2(fd[j][1],1);
                    }
                    printf("%d is size of char***\n", pStrCt[i]);
                    printf("Putting in %s for the %dth command\n", commandHolder[i][j][0], i);
                    int err = execvp(commandHolder[i][j][0], commandHolder[i][j]);
                        if (err < 0)
                        {
                            perror("execvp");
                        }
                        else{
                        }
                }
                else if(pid[j] == -1){
                    printf("Could not execute command\n %d", pid);
                }
            }
            waitpid(-1, NULL, 0);
        }

		free(commandHolder);
		free(ibuf);
	}
	return 0;
}
