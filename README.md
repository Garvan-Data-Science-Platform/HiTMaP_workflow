# HiTMaP_workflow
A workflow wrapper around the [HiTMaP R package from UOA]((https://github.com/MASHUOA/HiTMaP))

## Requirements
- Nextflow
- A HiTMaP docker or singularity image

### Docker image
There are a few options for obtaining a HiTMaP docker image:
- An image is published by the Mass Spectrometry Hub (MaSH) at the University of Auckland (UOA) and is available on dockerhub at `mashuoa/hitmap`
- You can build your own minimal docker image using the files in `docker/`

#### Building the docker image
Run the steps below to build a HiTMaP docker image. Supply the `VERSION` build argument to `docker build` to specify a branch, tag, or commit of the [official HiTMaP git repository](https://github.com/MASHUOA/HiTMaP) to install.

To build on Intel/x86_64 architecutres, run the following:

```bash
cd docker/

COMMIT=df20be1

docker build -t hitmap:${COMMIT} --build-arg VERSION=${COMMIT} .
```

If your computer uses an ARM architecture (e.g. Mac M-series), you will need to instead build the image from the `Dockerfile_arm64` Dockerfile:

```bash
cd docker/

COMMIT=df20be1

docker build -t hitmap:${COMMIT} --build-arg VERSION=${COMMIT} -f Dockerfile_arm64 .
```

Note that the initial build process will take up to an hour. Subsequent builds, even when using different HiTMaP versions, should take considerably less time as they can rely on the cached base layer from the initial build.

### Singularity
No official singularity image has been published, although the docker image that can be created by the above steps can be converted to a singularity image:

```bash
# Create a singularity image from a remote docker repository,
# e.g. Google Artifact Registry
# Using australia-southeast1-docker.pkg.dev/my-project/hitmap_repo/hitmap:latest as an example:
singularity build hitmap.sif docker://australia-southeast1-docker.pkg.dev/my-project/hitmap_repo/hitmap:latest

# Alternatively, you can use the singularity pull command:
singularity pull docker://australia-southeast1-docker.pkg.dev/my-project/hitmap_repo/hitmap:latest

# Create a singularity image from a local docker repository
# Assumes both docker and singularity are installed on the same machine
# Using the local image hitmap:latest as an example:
singularity build hitmap.sif docker-daemon://local/hitmap:latest
```

#### Pulling from private Artifact Registry repositories
If you run into authentication issues when attempting to run `singularity pull` from a private Google Artifact Registry repository, you may have to set the `SINGULARITY_DOCKER_USERNAME` and `SINGULARITY_DOCKER_PASSWORD` environemnt variables. This will also require using the `gcloud` command line tool to generate a temporary access token for authenticating with Google Cloud.

```bash
# Ensure you have already logged into Google Cloud from the terminal
gcloud auth login
# Follow the prompts to complete login.

# Set the docker environment variables
export SINGULARITY_DOCKER_USERNAME=oauth2accesstoken
export SINGULARITY_DOCKER_PASSWORD=$(gcloud auth print-access-token)

# Run singularity pull
singularity pull docker://australia-southeast1-docker.pkg.dev/my-project/hitmap_repo/hitmap:latest
```

## Running the workflow
The Nextflow workflow is run as follows:

```bash
nextflow run main.nf \
    --config assets/config.R \
    --datafile /path/to/data_file.imzML \
    --ibdfile /path/to/data_file.ibd \
    --fasta /path/to/reference.fasta \
    --hitmap_container [hitmap:latest | hitmap.sif] \
    -profile [docker | gadi | dice] \
    [-resume]
```

In most cases, you will likely want to run the workflow on an HPC system. The current repository contains two profiles, one for NCI's gadi (`gadi`) and another for the Garvan's HPC (`dice`). Both of these profiles use singularity, so a `.sif` image should be supplied to `--hitmap_container`.

If running a small data set on a local machine with docker installed, you can instead use the `docker` profile and supply a docker image to `--hitmap_container` (e.g. `--hitmap_container hitmap:latest` or `--hitmap_container australia-southeast1-docker.pkg.dev/my-project/hitmap_repo/hitmap:latest`).

The `-resume` flag is an optional but very useful flag that tells Nextflow to re-use the outputs of successful runs when re-running the pipeline. This is useful in cases such as where a job has failed due to low memory or disk space and needs to be re-run with higher resources. In such a case, the outputs of preceding jobs that ran successfully would be used, rather than re-running the whole pipeline from scratch.

### Memory requirements
By default, the workflow requests 16GB of memory to run each stage of the workflow. If you would like to increase or decrease this value, you can supply the `--memory` parameter on the command line:

```bash
nextflow run main.nf \
    --memory 32 \
    ...
```

### Workflow stages
This Nextflow workflow is divided into three stages:
1. Candidate list generation
2. IMS analysis
3. Plotting

Each stage outputs a `.tar` file in the `results/` directory that can be optionally passed to future runs of the workflow to skip running that stage again.

The workflow stages are run by specifying one of four run modes when running the pipeline (specified with `--mode <MODE>`):
- `full`: Run all three stages in order.
    - This is the default; if running the full pipeline, you can omit the `--mode` parameter.
- `candidates`: Just run the candidate list generation stage.
- `ims`: Run IMS analysis.
    - If a previously-generated `candidates` stage output is provided (with `--candidates /path/to/candidates.tar`), only IMS analysis will be performed. However, if `--candidates` is not supplied, the `candidates` stage will run first.
- `plot`: Run plotting.
    - If a previously-generated `ims` stage output is provided (with `--ims /path/to/ims.tar`), only plotting will be performed. However, if `--ims` is not supplied, the `ims` stage will run first.
    - Furthermore, the `candidates` stage will also be run if neither `--ims` nor `--candidates` are supplied.

### Input files
The following files are required when running the pipeline:
- Data files in `.imzML` and `.ibd` format, supplied with `--datafile` and `--ibdfile`, respectively
- Reference protein FASTA file (`.fasta` or `.fa`), supplied with `--fasta`
- Pipeline configuration file, supplied with `--config`.
    - This is a `.R` file that provides all the parameters to the HiTMaP workflow. A template is provided in `assets/config.R`.

A few optional input files can also be supplied:
- A virtual segmentation rank file, in CSV format, supplied with `--rankfile`
- An image rotation file, in CSV format, supplied with `--rotationfile`
