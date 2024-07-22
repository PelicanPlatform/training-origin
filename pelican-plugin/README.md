# Materials for PEARC24 Pelican Tutorial

Clone repository and then open the [README.ipynb](README.ipynb) file.

Alternatively, the commands are listed below. 

```bash
WORKDIR=$HOME/pearc24-pelican-jobs
echo $WORKDIR
```

## Recap: Fetching Data with Pelican

This set of commands downloads a test data file (in a sequence data format) from the Open Science Data Federation. 


```bash
cd $WORKDIR/data

OSDF=pelican://osg-htc.org
OBJ_PATH=ospool/uc-shared/public/osg-training/tutorial-fastqc/test.fastq
```


```bash
pelican object get $OSDF/$OBJ_PATH test.fastq
```

The following command should display the beginning of a genomic sequence file: 


```bash
head test.fastq
```

## Sample Job Submission


```bash
cd $WORKDIR/sample
```

Look at the contents of the HTCondor job submit file below. There should be some familiar elements (resource requests, where to save stdout/stderr/log files, what commands to run) and some potentially new elements (transferring files). 


```bash
cat sample.submit
```


```bash
condor_submit sample.submit
```


```bash
condor_q
```


```bash
cat job*.output
```


```bash
cat output*.txt
```

## Job Submission with Pelican

### One Job Fetching a Container and Data File


```bash
cd $WORKDIR/fastqc
```


```bash
ls -lh
```

We are now going to submit a slightly more complex job example. This job will fetch both the `test.fastq` file from the OSDF that we used a minute ago, as well as a container with the `fastQC` bioinformatics program. 


```bash
grep "pelican" single-fastqc.submit
```

The job itself will run the FastQC program on the fetched data file and produce a visualization, which will get written back to the `results` folder


```bash
cat single-fastqc.submit
```


```bash
condor_submit single-fastqc.submit
```


```bash
condor_q
```


```bash
ls results/
```

One of the script commands was an `ls` so we can see that the `test.fastq` was downloaded by looking at the standard output file. 


```bash
cat logs/*.out
```

### Multiple Jobs Fetching a Single Container and Unique Data Files


```bash
cd $WORKDIR/fastqc
```

Because the Pelican object links can be quite long, it's helpful to use intermediate variables in the submit file. 


```bash
grep "OBJ_LOC" many-fastqc.submit
```

Finally, we'll run the same FastQC analysis, but with multiple data files (again, being fetched from the OSDF). 


```bash
cat many-fastqc.submit
```


```bash
condor_submit many-fastqc.submit
```


```bash
condor_q
```


```bash
ls results/
```


```bash
cat logs/*.out
```
