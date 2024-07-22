# PEARC24 Pelican Tutorial - Using Data from OSDF

## Other Tutorial Sections

- "Deploy a Pelican Origin" ([README.md](/README.md))
- "Exploring Tokens in a Pelican Ecosystem" ([AUTHORIZATION.md](/AUTHORIZATION.md))

## Using Data From the OSDF

Accompanying slides: [here](https://docs.google.com/presentation/d/1RrSfgQIgDNI6EboqSOk-7OVRTlSfcdmPsI73JrjGzsQ/edit#slide=id.g2ed4e8e0b58_0_0)

**Jump to:**

* [Setup](#setup)
* [Recap](#recap-fetching-data-with-pelican)
* [Sample Job Submission](#sample-job-submission)
* [Job Submission with Pelican and OSDF](#job-submission-with-pelican-and-osdf)

## Setup

Access a notebook here: https://notebook.ospool.osg-htc.org/

Authenticate with one of the following: 
* GitHub
* ORCID
* ACCESS ID
* Your local university credentials

Select the “Basic” server and click “Start”

Clone repository and then open the [README.ipynb](README.ipynb) file.

Alternatively, the commands are listed below. 

-----

```bash
WORKDIR=$HOME/training-origin/pelican-plugin
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

## Job Submission with Pelican and OSDF

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

## Job Submission with Pelican and YOUR origin

Let's go back to our sample directory and try to download a file from YOUR origin in a job!


```bash
cd $WORKDIR/sample
```


```bash
cat sample-origin.submit
```


```bash
condor_submit sample-origin.submit
```


```bash
condor_q
```
