# Strip

Strip is a programming language.

## How to build and run?

Run the following command to build the project in the main project folder

```bash
./build.sh
```

The excutable after building is kept inside the build folder in the main project directory.

To be able to run the program as a command from any directory, run the following command from the mentioned bin folder

```bash
cd bin
sudo mkdir /opt/strip
sudo cp strip /opt/strip/
sudo ln -s /opt/strip/strip /bin/usr/strip
```

To run the program on a targer file, let's say `<filename>`, use the program as given below

```bash
strip <filename>
```