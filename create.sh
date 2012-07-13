#/bin/tcsh

# ***EDIT THESE FIELDS ***
set P12 =     location of the *.p12 file from Apple Key Chain
set DIR =     Directory to store files for the pass
set PASSWORD= Password for your key

set CWD=`pwd`

openssl pkcs12 -passin pass:$PASSWORD -in $P12 -clcerts -nokeys -out certificate.pem 
openssl pkcs12 -passin pass:$PASSWORD  -in $P12 -nocerts -out key.pem

cd $DIR

rm -f manifest.json *.pkpass signature *~
set MANIFEST = $CWD/manifest.json
echo '{' > $MANIFEST
foreach i (*)
  set sha1 = `openssl sha1 $i | cut -d' ' -f2`
  echo \'$i\' : \'$sha1\', >> $MANIFEST
end
echo '}' >> $MANIFEST
cp $MANIFEST .
openssl smime -passin pass:$PASSWORD  -binary -sign -signer $CWD/certificate.pem -inkey $CWD/key.pem -in manifest.json -out signature xs-outform DER

zip test.pkpass *
cp test.pkpass ~/Sites/passbook/.
cd $CWD

