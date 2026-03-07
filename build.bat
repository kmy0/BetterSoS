git pull --recurse-submodules
git submodule update --init --recursive
pushd deps\ref_system_action
call build.bat
popd
md bin\reframework\plugins
robocopy reframework bin/reframework /mir
robocopy deps\ref_system_action\bin bin\reframework\plugins ref_system_action.dll
tar -a -cf BetterSoS.zip -C bin reframework
rmdir /s /q bin