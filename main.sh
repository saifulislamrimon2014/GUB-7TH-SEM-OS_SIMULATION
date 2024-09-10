DEFAULT_USERNAME="user"
DEFAULT_PASSWORD="password"


login() {
    local input_username input_password

    echo "Please enter your credentials:"
    read -p "Username: " input_username
    read -sp "Password: " input_password
    echo

    if [[ "$input_username" == "$DEFAULT_USERNAME" && "$input_password" == "$DEFAULT_PASSWORD" ]]; then
        echo "Login successful!"
        return 0
    else
        echo "Login failed!"
        return 1
    fi
}







function CPUScheFCFS {

p=()
bt=()
wt=()
tat=()

read -p "Enter the number of processes: " n
echo

for ((i=0; i<n; i++))
do
    read -p "Enter the Burst Time for process $i: " bt[i]
done

wt[0]=0
wtavg=0
tat[0]=${bt[0]}
tatavg=${bt[0]}

for ((i=1; i<n; i++))
do
    wt[i]=${tat[i-1]}
    tat[i]=$((bt[i] + wt[i]))
    wtavg=$((wtavg + wt[i]))
    tatavg=$((tatavg + tat[i]))
done

echo -e "\nPROCESS\t\tBURST TIME\tWAITING TIME\tTURNAROUND TIME"

for ((i=0; i<n; i++))
do
    echo -e "P$i\t\t${bt[i]}\t\t${wt[i]}\t\t${tat[i]}"
done

wtavg_float=$(awk "BEGIN {printf \"%.2f\", $wtavg / $n}")
tatavg_float=$(awk "BEGIN {printf \"%.2f\", $tatavg / $n}")

echo -e "\nAverage Waiting Time --> $wtavg_float"
echo -e "Average Turnaround Time --> $tatavg_float"
echo
mainmenu
}

function CPUScheSJF {

p=()
bt=()
wt=()
tat=()

read -p "Enter the number of processes: " n
echo


for ((i=0; i<n; i++))
do
    p[$i]=$i
    read -p "Enter Burst Time for Process P$i: " bt[$i]
done

for ((i=0; i<n-1; i++))
do
    for ((k=i+1; k<n; k++))
    do
        if [ ${bt[$i]} -gt ${bt[$k]} ]
        then

            temp=${bt[$i]}
            bt[$i]=${bt[$k]}
            bt[$k]=$temp

            temp=${p[$i]}
            p[$i]=${p[$k]}
            p[$k]=$temp
        fi
    done
done

wt[0]=0
wtavg=0
tat[0]=${bt[0]}
tatavg=${bt[0]}
for ((i=1; i<n; i++))
do
    wt[$i]=${tat[$((i-1))]}
    tat[$i]=$((wt[$i] + bt[$i]))
    wtavg=$((wtavg + wt[$i]))
    tatavg=$((tatavg + tat[$i]))
done

echo -e "\n\t PROCESS \tBURST TIME \t WAITING TIME\t TURNAROUND TIME"
for ((i=0; i<n; i++))
do
    printf "\n\t P%s \t\t\t %s \t\t\t %s\t\t\t\t%s" ${p[$i]} ${bt[$i]} ${wt[$i]} ${tat[$i]}
done

wtavg=$(awk "BEGIN {printf \"%.2f\", $wtavg / $n}")
tatavg=$(awk "BEGIN {printf \"%.2f\", $tatavg / $n}")
echo -e "\n\nAverage Waiting Time --> $wtavg"
echo -e "Average Turnaround Time --> $tatavg"
echo
mainmenu
}

function CPUSchePRIORITY {
compare() {
    local a_burstTime=$1
    local a_priority=$2
    local b_burstTime=$3
    local b_priority=$4

    if [ $a_priority -ne $b_priority ]; then
        [ $a_priority -gt $b_priority ]
    else
        [ $a_burstTime -lt $b_burstTime ]
    fi
}

read -p "Enter the number of processes: " n

declare -a p=()
declare -a bt=()
declare -a priority=()
declare -a wt=()
declare -a tat=()

for ((i = 0; i < n; i++)); do
    p[$i]=$((i + 1))
    read -p "Enter Burst Time for Process P$((i + 1)): " bt[$i]
    read -p "Enter Priority for Process P$((i + 1)): " priority[$i]
done

for ((i = 0; i < n; i++)); do
    for ((j = i + 1; j < n; j++)); do
        if compare "${bt[$i]}" "${priority[$i]}" "${bt[$j]}" "${priority[$j]}"; then
            
            temp=${bt[$i]}
            bt[$i]=${bt[$j]}
            bt[$j]=$temp

            
            temp=${p[$i]}
            p[$i]=${p[$j]}
            p[$j]=$temp

           
            temp=${priority[$i]}
            priority[$i]=${priority[$j]}
            priority[$j]=$temp
        fi
    done
done


wt[0]=0
tat[0]=${bt[0]}
for ((i = 1; i < n; i++)); do
    wt[$i]=$((wt[$i - 1] + bt[$i - 1]))
    tat[$i]=$((wt[$i] + bt[$i]))
done


echo -e "\nProcess \t Burst Time \t Priority \t Waiting Time \t Turnaround Time"
for ((i = 0; i < n; i++)); do
    echo -e "P${p[$i]} \t\t\t\t${bt[$i]} \t\t\t\t${priority[$i]} \t\t\t\t${wt[$i]} \t\t\t\t ${tat[$i]}"
done
mainmenu
}


function MFT {
local ms bs nob ef n
local mp=()
local tif=0
local p=0

# Input total memory available
read -p "Enter the total memory available (in Bytes): " ms

# Input block size
read -p "Enter the block size (in Bytes): " bs

# Calculate number of blocks and external fragmentation
nob=$((ms / bs))
ef=$((ms - nob * bs))

# Input number of processes
read -p "Enter the number of processes: " n

# Input memory required for each process
for ((i = 0; i < n; i++)); do
    read -p "Enter memory required for process $((i + 1)) (in Bytes): " mp[$i]
done

# Output number of blocks available
echo -e "\nNo. of Blocks available in memory: $nob"

# Output process details
echo -e "\nPROCESS\tMEMORY REQUIRED\tALLOCATED\tINTERNAL FRAGMENTATION"

for ((i = 0; i < n && p < nob; i++)); do
    echo -n -e "\n$((i + 1))\t\t\t${mp[$i]}"

    if ((mp[i] > bs)); then
        echo -e "\t\t\t\tNO\t\t\t\t---"
    else
        local internal_frag=$((bs - mp[i]))
        echo -e "\t\t\t\tYES\t\t\t\t$internal_frag"
        tif=$((tif + internal_frag))
        p=$((p + 1))
    fi
done

if ((i < n)); then
    echo -e "\n\nMemory is Full, Remaining Processes cannot be accommodated."
fi

# Output total internal and external fragmentation
echo -e "\n\nTotal Internal Fragmentation is $tif"
echo -e "Total External Fragmentation is $ef"
mainmenu
}

function MVT {
local TotalMemory AvailableMemory i TotalMemoryAllocated ExternalFrag ProcessCount choice
local MemoryRequiredforEachProcess=()


AvailableMemory=0
i=0
TotalMemoryAllocated=0
ExternalFrag=0
ProcessCount=0
choice='y'


read -p "Enter the total memory available: " TotalMemory
AvailableMemory=$TotalMemory


while [ "$choice" != "n" ]; do
    read -p "Enter memory required for process $((i + 1)) (in Bytes): " MemoryRequiredforEachProcess[i]

    if [ $((TotalMemory - TotalMemoryAllocated)) -ge ${MemoryRequiredforEachProcess[i]} ]; then
        TotalMemoryAllocated=$((TotalMemoryAllocated + MemoryRequiredforEachProcess[i]))
        ProcessCount=$((ProcessCount + 1))
        echo "Memory is allocated for process $((i + 1))"
    else
        echo "Not enough space!"
        i=$((i - 1))
    fi

    read -p "Do you want to continue(y/n): " choice
    i=$((i + 1))
done

if [ $TotalMemory -le $TotalMemoryAllocated ]; then
    echo "Memory is Full!"
fi


echo -e "\n\nTotal Memory Available: $TotalMemory\n"
echo -e "Process\t\tMemory Allocated"

for ((j = 0; j < ProcessCount; j++)); do
    if [ $AvailableMemory -ge ${MemoryRequiredforEachProcess[j]} ]; then
        echo -e "$((j + 1))\t\t\t\t${MemoryRequiredforEachProcess[j]}"
    else
        break
    fi
    AvailableMemory=$((AvailableMemory - MemoryRequiredforEachProcess[j]))
done

echo -e "\nTotal Memory Allocated is $TotalMemoryAllocated"
echo -e "Total External Fragmentation is $((TotalMemory - TotalMemoryAllocated))"
mainmenu
}

function FirstFit {
  
    num_blocks=0
    num_files=0
    block_size=()
    file_size=()
    block_flag=()
    file_flag=()
    fragmentation=()

    for ((i = 0; i < 100; i++)); do
        block_size[i]=0
        file_size[i]=0
        block_flag[i]=0
    done

    echo -n "Enter the number of blocks: "
    read num_blocks
    echo -n "Enter the number of files: "
    read num_files

    echo "Enter the block sizes: "
    for ((i = 0; i < num_blocks; i++)); do
        echo -n "Block $((i+1)): "
        read block_size[i]
    done

    echo "Enter the file sizes: "
    for ((i = 0; i < num_files; i++)); do
        echo -n "File $((i+1)): "
        read file_size[i]
    done

    for ((i = 0; i < num_files; i++)); do
        for ((j = 0; j < num_blocks; j++)); do
            if [[ ${block_flag[j]} -eq 0 && ${block_size[j]} -ge ${file_size[i]} ]]; then
                file_flag[i]=$((j+1))
                fragmentation[i]=$((block_size[j] - file_size[i]))
                block_flag[j]=1
                break
            fi
        done
    done

    echo -e "\nFile No\tFile Size\tBlock No\tBlock Size\tFragmentation"
    for ((i = 0; i < num_files; i++)); do
        echo -e "$((i+1))\t\t${file_size[i]}\t\t\t${file_flag[i]}\t\t\t${block_size[file_flag[i]-1]}\t\t\t${fragmentation[i]}"
    done

}



function BestFit {

num_blocks=0
num_files=0
block_size=()
file_size=()
block_flag=()
temp=0
smallest=0
file_flag=()
fragmentation=()

for ((i = 1; i < 100; i++)); do
    block_size[i]=0
    file_size[i]=0
    block_flag[i]=0
done

echo -n "Enter the number of blocks: "
read num_blocks
echo -n "Enter the number of files: "
read num_files

echo "Enter the block sizes: "
for ((i = 1; i <= num_blocks; i++)); do
    echo -n "Block $i: "
    read block_size[i]
done

echo "Enter the file sizes: "
for ((i = 1; i <= num_files; i++)); do
    echo -n "File $i: "
    read file_size[i]
done

for ((i = 1; i <= num_files; i++)); do
    smallest=99999
    for ((j = 1; j <= num_blocks; j++)); do
        if [[ ${block_flag[j]} -ne 1 ]]; then
            temp=$((block_size[j] - file_size[i]))
            if [[ $temp -ge 0 && $temp -lt $smallest ]]; then
                smallest=$temp
                file_flag[i]=$j
            fi
        fi
    done
    fragmentation[i]=$smallest
    block_flag[${file_flag[i]}]=1
done

echo -e "\nFile No\tFile Size\tBlock No\tBlock Size\tFragmentation"
for ((i = 1; i <= num_files; i++)); do
    echo -e "$i\t\t${file_size[i]}\t\t\t${file_flag[i]}\t\t\t${block_size[file_flag[i]]}\t\t\t${fragmentation[i]}"
done

}


function WorstFit {


max=25
num_blocks=0
num_files=0
block_size=()
file_size=()
fragmentation=()
block_flag=()
file_flag=()
temp=0
lowest=0

for ((i = 0; i < max; i++)); do
    block_size[i]=0
    file_size[i]=0
    fragmentation[i]=0
    block_flag[i]=0
    file_flag[i]=0
done

echo -n "Enter the number of blocks:"
read num_blocks

echo -n "Enter the number of files:"
read num_files

echo -e "\nEnter the size of the blocks:-"
for ((i = 1; i <= num_blocks; i++)); do
    echo -n "Block $i:"
    read block_size[i]
done

echo -e "Enter the size of the files:-"
for ((i = 1; i <= num_files; i++)); do
    echo -n "File $i:"
    read file_size[i]
done

for ((i = 1; i <= num_files; i++)); do
    for ((j = 1; j <= num_blocks; j++)); do
        if [[ ${block_flag[j]} -ne 1 ]]; then
            temp=$((block_size[j] - file_size[i]))
            if [[ $temp -ge 0 ]]; then
                if [[ $lowest -lt $temp ]]; then
                    file_flag[i]=$j
                    lowest=$temp
                fi
            fi
        fi
    done
    fragmentation[i]=$lowest
    block_flag[${file_flag[i]}]=1
    lowest=0
done

echo -e "\nFile_no \tFile_size \tBlock_no \tBlock_size \tFragment"
for ((i = 1; i <= num_files; i++)); do
    echo -e "$i\t\t\t${file_size[i]}\t\t\t${file_flag[i]}\t\t\t${block_size[file_flag[i]]}\t\t\t${fragmentation[i]}"
done

}


function NextFit {

max=25
num_blocks=0
num_files=0
block_size=()
file_size=()
fragmentation=()
block_flag=()
file_flag=()
temp=0
lowest=0
last_allocated=1

for ((i = 0; i < max; i++)); do
    block_size[i]=0
    file_size[i]=0
    fragmentation[i]=0
    block_flag[i]=0
    file_flag[i]=0
done

echo -n "Enter the number of blocks:"
read num_blocks

echo -n "Enter the number of files:"
read num_files

echo -e "\nEnter the size of the blocks:-"
for ((i = 1; i <= num_blocks; i++)); do
    echo -n "Block $i:"
    read block_size[i]
done

echo -e "Enter the size of the files:-"
for ((i = 1; i <= num_files; i++)); do
    echo -n "File $i:"
    read file_size[i]
done

for ((i = 1; i <= num_files; i++)); do
    for ((j = last_allocated; j <= num_blocks; j++)); do
        if [[ ${block_flag[j]} -eq 0 && ${block_size[j]} -ge ${file_size[i]} ]]; then
            file_flag[i]=$j
            fragmentation[i]=$((block_size[j] - file_size[i]))
            block_flag[j]=1
            last_allocated=$((j + 1))
            break
        fi
    done
    if [[ ${file_flag[i]} -eq 0 ]]; then
        for ((j = 1; j < last_allocated; j++)); do
            if [[ ${block_flag[j]} -eq 0 && ${block_size[j]} -ge ${file_size[i]} ]]; then
                file_flag[i]=$j
                fragmentation[i]=$((block_size[j] - file_size[i]))
                block_flag[j]=1
                last_allocated=$((j + 1))
                break
            fi
        done
    fi
done

echo -e "\nFile_no \tFile_size \tBlock_no \tBlock_size \tFragment"
for ((i = 1; i <= num_files; i++)); do
    echo -e "$i\t\t\t${file_size[i]}\t\t\t${file_flag[i]}\t\t\t${block_size[file_flag[i]]}\t\t\t${fragmentation[i]}"
done

}

function FCFS {
    
calculateHitMissRatio() {
    local hits=$1
    local numberOfPages=$2
    local hitRatio=$(awk "BEGIN {print $hits / $numberOfPages}")
    local missRatio=$(awk "BEGIN {print 1 - $hitRatio}")
    
    echo "Hit Ratio: $hitRatio"
    echo "Miss Ratio: $missRatio"
}

pageReplacement() {
    local pages=("${!1}")
    local numberOfPages=$2
    local numberOfFrames=$3
    local memory=()
    local pageFaultCount=0
    local memoryIndex=0
    local hits=0

    echo "The Page Replacement Process is −−>"
    for ((i=0; i<numberOfPages; i++)); do
        local pageFound=false
        for ((j=0; j<numberOfFrames; j++)); do
            if [ "${memory[j]}" == "${pages[i]}" ]; then
                pageFound=true
                ((hits++))
                break
            fi
        done
        if ! $pageFound; then
            memory[$memoryIndex]=${pages[i]}
            ((memoryIndex++))
            ((pageFaultCount++))
        fi
        for ((k=0; k<numberOfFrames; k++)); do
            if [ -z "${memory[k]}" ]; then
                echo -n -e "\t-1"
            else
                echo -n -e "\t${memory[k]}"
            fi
        done
        if ! $pageFound; then
            echo -e "\tPage Fault No: $pageFaultCount"
        else
            echo
        fi
        if [ $memoryIndex -eq $numberOfFrames ]; then
            memoryIndex=0
        fi
    done
    calculateHitMissRatio $hits $numberOfPages

    return $pageFaultCount
}

read -p "Enter number of pages: " numberOfPages
echo "Enter the pages: "
pages=()
for ((i=0; i<numberOfPages; i++)); do
    read pages[i]
done

read -p "Enter number of frames: " numberOfFrames

for ((i=0; i<numberOfFrames; i++)); do
    memory[i]=-1
done

pageReplacement pages[@] $numberOfPages $numberOfFrames
pageFaults=$?
echo "The number of Page Faults using FIFO is: $pageFaults"

}

function LRU {
    
calculateHitMissRatio() {
    local hits=$1
    local numberOfPages=$2
    local hitRatio=$(awk "BEGIN {print $hits / $numberOfPages}")
    local missRatio=$(awk "BEGIN {print 1 - $hitRatio}")
    
    echo "Hit Ratio: $hitRatio"
    echo "Miss Ratio: $missRatio"
}

pageReplacement() {
    local pages=("${!1}")
    local numberOfPages=$2
    local numberOfFrames=$3
    local memory=()
    local timeStamps=()
    local pageFaultCount=0
    local hits=0
    local currentTime=0


    for ((i=0; i<numberOfFrames; i++)); do
        memory[i]=-1
        timeStamps[i]=-1
    done

    echo "The Page Replacement Process is ->"
    for ((i=0; i<numberOfPages; i++)); do
        currentTime=$((currentTime + 1))
        currentPage=${pages[i]}
        pageFound=false


        for ((j=0; j<numberOfFrames; j++)); do
            if [ "${memory[j]}" == "$currentPage" ]; then
                pageFound=true
                hits=$((hits + 1))
                timeStamps[j]=$currentTime
                break
            fi
        done

        if ! $pageFound; then

            pageFaultCount=$((pageFaultCount + 1))
            lruIndex=0


            for ((j=1; j<numberOfFrames; j++)); do
                if [ "${timeStamps[j]}" -lt "${timeStamps[lruIndex]}" ]; then
                    lruIndex=$j
                fi
            done

            memory[lruIndex]=$currentPage
            timeStamps[lruIndex]=$currentTime
        fi


        for ((k=0; k<numberOfFrames; k++)); do
            if [ -z "${memory[k]}" ]; then
                echo -n -e "\t-1"
            else
                echo -n -e "\t${memory[k]}"
            fi
        done
        if ! $pageFound; then
            echo -e "\tPage Fault No: $pageFaultCount"
        else
            echo
        fi
    done

    calculateHitMissRatio $hits $numberOfPages

    return $pageFaultCount
}

read -p "Enter number of pages: " numberOfPages
echo "Enter the pages: "
pages=()
for ((i=0; i<numberOfPages; i++)); do
    read pages[i]
done

read -p "Enter number of frames: " numberOfFrames

for ((i=0; i<numberOfFrames; i++)); do
    memory[i]=-1
done

pageReplacement pages[@] $numberOfPages $numberOfFrames
pageFaults=$?
echo "The number of Page Faults using LRU is: $pageFaults"

}

function OPR {
    
calculateHitMissRatio() {
    local hits=$1
    local numberOfPages=$2
    local hitRatio=$(awk "BEGIN {print $hits / $numberOfPages}")
    local missRatio=$(awk "BEGIN {print 1 - $hitRatio}")
    
    echo "Hit Ratio: $hitRatio"
    echo "Miss Ratio: $missRatio"
}

findOptimal() {
    local memory=("${!1}")
    local pages=("${!2}")
    local numberOfFrames=$3
    local currentIndex=$4
    local maxDistance=-1
    local optimalIndex=0

    for ((i=0; i<numberOfFrames; i++)); do
        local found=false
        for ((j=currentIndex+1; j<${#pages[@]}; j++)); do
            if [ "${memory[i]}" == "${pages[j]}" ]; then
                found=true
                if [ $j -gt $maxDistance ]; then
                    maxDistance=$j
                    optimalIndex=$i
                fi
                break
            fi
        done
        if ! $found; then
            echo $i
            return
        fi
    done
    echo $optimalIndex
}

pageReplacement() {
    local pages=("${!1}")
    local numberOfPages=$2
    local numberOfFrames=$3
    local memory=()
    local pageFaultCount=0
    local hits=0


    for ((i=0; i<numberOfFrames; i++)); do
        memory[i]=-1
    done

    echo "The Page Replacement Process is ->"
    for ((i=0; i<numberOfPages; i++)); do
        local currentPage=${pages[i]}
        local pageFound=false


        for ((j=0; j<numberOfFrames; j++)); do
            if [ "${memory[j]}" == "$currentPage" ]; then
                pageFound=true
                hits=$((hits + 1))
                break
            fi
        done

        if ! $pageFound; then

            pageFaultCount=$((pageFaultCount + 1))


            optimalIndex=$(findOptimal memory[@] pages[@] $numberOfFrames $i)
            memory[$optimalIndex]=$currentPage
        fi


        for ((k=0; k<numberOfFrames; k++)); do
            if [ "${memory[k]}" == "-1" ]; then
                echo -n -e "\t-1"
            else
                echo -n -e "\t${memory[k]}"
            fi
        done
        if ! $pageFound; then
            echo -e "\tPage Fault No: $pageFaultCount"
        else
            echo
        fi
    done

    calculateHitMissRatio $hits $numberOfPages

    return $pageFaultCount
}

read -p "Enter number of pages: " numberOfPages
echo "Enter the pages: "
pages=()
for ((i=0; i<numberOfPages; i++)); do
    read pages[i]
done

read -p "Enter number of frames: " numberOfFrames

pageReplacement pages[@] $numberOfPages $numberOfFrames
pageFaults=$?
echo "The number of Page Faults using OPR is: $pageFaults"

}

function semaphore {

NUM_PHILOSOPHERS=5
MAX_SLEEP=3

declare -a forks

for (( i = 0; i < NUM_PHILOSOPHERS; i++ )); do
    forks[$i]=0  # 0 means available, 1 means taken
done

philosopher() {
    local id=$1
    local leftFork=$id
    local rightFork=$(( ($id + 1) % NUM_PHILOSOPHERS ))

    while true; do
        # Thinking
        echo "Philosopher $id is thinking."

        sleep $(( RANDOM % MAX_SLEEP + 1 ))  # Random sleep time between 1 and MAX_SLEEP

        # Pick up forks
        echo "Philosopher $id is trying to pick up forks."

        if [ $leftFork -lt $rightFork ]; then
            while ! try_take_forks $leftFork $rightFork; do
                sleep 1
            done
        else
            while ! try_take_forks $rightFork $leftFork; do
                sleep 1
            done
        fi

        # Eating
        echo "Philosopher $id is eating."

        sleep $(( RANDOM % MAX_SLEEP + 1 ))  # Random sleep time between 1 and MAX_SLEEP

        # Put down forks
        put_down_forks $leftFork $rightFork
    done
}

try_take_forks() {
    local left=$1
    local right=$2

    if [ ${forks[$left]} -eq 0 ] && [ ${forks[$right]} -eq 0 ]; then
        forks[$left]=1
        forks[$right]=1
        return 0  # Success
    else
        return 1  # Failure
    fi
}

put_down_forks() {
    local left=$1
    local right=$2

    forks[$left]=0
    forks[$right]=0
}

# Main program

# Start philosophers as separate processes
for (( i = 0; i < NUM_PHILOSOPHERS; i++ )); do
    philosopher $i &
done

# Wait for all philosophers to finish
wait

}



function mainmenu {



    echo "+------------------------------------------------+"
    echo "|              WELCOME TO                        |"
    echo "|        A Comprehensive OS Simulation           |"
    echo "+------------------------------------------------+"

 
    echo "|                                                |"
    echo "|  WE ARE OFFERING COMPLETE SIMULATION OF        |"
    echo "|  SEVERAL TECHNIQUES OF OPERATING SYSTEM:       |"
    echo "|  ____________________________________________  |"
    echo "|                                                |"
    echo "|  1. CPU Scheduling Algorithms                  |"
    echo "|  2. Memory Management Techniques               |"
    echo "|  3. Contiguous Memory Allocation Techniques    |"
    echo "|  4. Page Replacement Algorithms                |"
    echo "|  5. Thread Management Techniques               |"
    echo "|                                                |"
    echo "|  0. Exit Program                               |"
    echo "|                                                |"
    echo "+------------------------------------------------+"

  
    echo -n "  Enter your choice (0-5): "

read choice
if [ $choice -eq 1 ]; then
echo "|  ____________________________________________  |"
echo "|                                                |"
echo "|  1. CPU Scheduling Algorithms                  |"
echo "|                                                |"
echo "|------------------------------------------------|"
        echo -e "\n\n1. FIRST COME FIRST SERVE (FCFS)\n2. SHORTEST JOB FIRST (SJF)\n3. SHORTEST JOB FIRST WITH PRIORITY (PSJF)\n0. MAIN MENU"
        read -p "ENTER YOUR CHOICE: " choice
        if [ $choice -eq 1 ]; then
                echo -e "\n\nRUNNING: 1. FIRST COME FIRST SERVE (FCFS)"
                echo -e "_____________________________________________\n"
                CPUScheFCFS
                mainmenu
        elif [ $choice -eq 2 ]; then
                echo -e "\n\nRUNNING: 2. SHORTEST JOB FIRST (SJF)"
                echo -e "_____________________________________________\n"
                CPUScheSJF
                mainmenu
        elif [ $choice -eq 3 ]; then
                
                echo -e "\n\nRUNNING: 3. SHORTEST JOB FIRST WITH PRIORITY (PSJF)"
                echo -e "_____________________________________________\n"
                CPUSchePRIORITY
                mainmenu
        elif [ $choice -eq 0 ]; then
                clear
                mainmenu
        else
                echo "INVALID CHOICE!"
                clear
                mainmenu
        fi

elif [ $choice -eq 2 ]; then
echo "|  ____________________________________________  |"
echo "|                                                |"
echo "|  2. Memory Management Algorithms               |"
echo "|                                                |"
echo "|------------------------------------------------|"
    echo -e "\n\n1. MULTIPROGRAMMING WITH FIXED NUMBER OF TASKS (MFT)\n2. MULTIPROGRAMMING WITH VARIABLE NUMBER OF TASKS (MVT)\n0. MAIN MENU"
    read -p "ENTER YOUR CHOICE: " choice
    if [ $choice -eq 1 ]; then
        echo -e "\n\nRUNNING: 1. MULTIPROGRAMMING WITH FIXED NUMBER OF TASKS (MFT)"
        echo -e "_____________________________________________\n"
        MFT
        mainmenu
    elif [ $choice -eq 2 ]; then
        echo -e "\n\nRUNNING: 2. MULTIPROGRAMMING WITH VARIABLE NUMBER OF TASKS (MVT)"
        echo -e "_____________________________________________\n"
        MVT
        mainmenu
    elif [ $choice -eq 0 ]; then
        mainmenu
    else
        echo "INVALID CHOICE!"
        clear
        mainmenu
    fi

elif [ $choice -eq 3 ]; then
echo "|  ____________________________________________  |"
echo "|                                                |"
echo "|  3. Contiguous Memory Allocation Techniques    |"
echo "|                                                |"
echo "|------------------------------------------------|"
    echo -e "\n\n1. FIRST FIT\n2. WORST FIT\n3. BEST FIT\n4. NEXT FIT\n0.MAIN MENU"
    read -p "ENTER YOUR CHOICE: " choice
    if [ $choice -eq 1 ]; then
        echo -e "\n\nRUNNING: 1.FIRST FIT"
        echo -e "_____________________________________________\n"
        FirstFit
        mainmenu
    elif [ $choice -eq 2 ]; then
        echo -e "\n\nRUNNING: 2. WORST FIT"
        echo -e "_____________________________________________\n"
        WorstFit
        mainmenu
    elif [ $choice -eq 3 ]; then
        echo -e "\n\nRUNNING: 2. BEST FIT"
        echo -e "_____________________________________________\n"
        BestFit
        mainmenu
        
    elif [ $choice -eq 4 ]; then
        echo -e "\n\nRUNNING: 2. NEXT FIT"
        echo -e "_____________________________________________\n"
        NextFit
        mainmenu
    elif [ $choice -eq 0 ]; then
        clear
        mainmenu
    else
        echo "INVALID CHOICE!"
        clear
        mainmenu
    fi
elif [ $choice -eq 4 ]; then
echo "|  ____________________________________________  |"
echo "|                                                |"
echo "|  4. Page Replacement Algorithms                |"
echo "|                                                |"
echo "|------------------------------------------------|"
    echo -e "\n\n1. FIRST COME FIRST SERVE (FCFS)\n2. LEAST RECENTLY USED (LRU)\n3. OPTIMAL PAGE REPLACEMENT (OPR)\n0. MAIN MENU"
    read -p "ENTER YOUR CHOICE: " choice
    if [ $choice -eq 1 ]; then
        echo -e "\n\nRUNNING: 1.FIRST COME FIRST SERVE (FCFS)"
        echo -e "_____________________________________________\n"
        FCFS
        mainmenu
    elif [ $choice -eq 2 ]; then
        echo -e "\n\nRUNNING: 2. LEAST RECENTLY USED (LRU)"
        echo -e "_____________________________________________\n"
        LRU
        mainmenu
    elif [ $choice -eq 3 ]; then
        echo -e "\n\nRUNNING: 2. OPTIMAL PAGE REPLACEMENT (OPR)"
        echo -e "_____________________________________________\n"
        OPR
        mainmenu
        
    elif [ $choice -eq 0 ]; then
        clear
        mainmenu
    else
        echo "INVALID CHOICE!"
        clear
        mainmenu
    fi
    
elif [ $choice -eq 5 ]; then
echo "|  ____________________________________________  |"
echo "|                                                |"
echo "|  5. Semaphore                                  |"
echo "|                                                |"
echo "|------------------------------------------------|"
    echo -e "\n\nRUNNING: 1. SEMAPHORE"
        echo -e "_____________________________________________\n"
        semaphore
        mainmenu
elif [ $choice -eq 0 ]; then
echo "|  ____________________________________________  |"
echo "|                                                |"
echo "|  THANK YOU FOR USING OUR PROGRAM               |"
echo "|  MD SAIFUL ISLAM RIMON - 213002039             |"
echo "|  DEPT. OF CSE                                  |"
echo "|  GREEN UNIVERSITY OF BANGLADESH                |"
echo "|                                                |"
echo "|------------------------------------------------|"
    echo -e "THANK YOU FOR USING OUR PROGRAM!"
    exit
else
    echo "INVALID CHOICE!"
    clear
    mainmenu
fi
}


if login; then
    mainmenu
else
    echo "Terminating script due to failed login. Try again!"
    echo ""
    login
fi

