#!/bin/sh

# set -eux


echo '*** Create Gift Zip Start!! ***'

cd `dirname $0`
CURRENT_DIR=`pwd`

# 出力フォルダを作成.
OUTPUT_DIR=~/Desktop/gift
echo ${OUTPUT_DIR}
if [ -e ${OUTPUT_DIR} ]; then
    # 既にある場合はフォルダを削除.
    rm -fr ${OUTPUT_DIR}
fi
mkdir ${OUTPUT_DIR}

# ギフトフォルダへ移動.
GIFT_DIR=${CURRENT_DIR}/../assets/anim/new
cd ${GIFT_DIR}

# ギフトのzipファイルを作成.
GIFT_LIST=`find ${GIFT_DIR} -type d -mindepth 1 -maxdepth 1`
for GIFT in ${GIFT_LIST};
do
    GIFT_NAME=`basename ${GIFT}`
    zip -q -r ${OUTPUT_DIR}/${GIFT_NAME}.zip ${GIFT_NAME}/ -x "*.DS_Store" "*__MACOSX*"
done

# JSONファイルの作成.
ORIGINAL_JSON_FILE=${CURRENT_DIR}/../assets/anim/manifest.json
OUTPUT_JSON=`cat ${ORIGINAL_JSON_FILE}`
GIFT_LENGTH=`echo ${OUTPUT_JSON} | jq -r '.gift | length'`
GIFT_ZIP_LIST=`find ${OUTPUT_DIR} -type f -name "*.zip" -mindepth 1 -maxdepth 1`
for GIFT_ZIP in ${GIFT_ZIP_LIST};
do
    GIFT_ZIP_FILE_NAME=`basename ${GIFT_ZIP} .zip`
    for i in $( seq 0 $((${GIFT_LENGTH} - 1)) ); do
        GIFT_ID=$(expr $(echo ${OUTPUT_JSON} | jq -r ".gift[${i}].id") - 3000)
        if [ "${GIFT_ZIP_FILE_NAME}" = "${GIFT_ID}" ]; then
            HASH=`md5 ${GIFT_ZIP} | awk '{ print $4 }'`
            SIZE=`wc -c ${GIFT_ZIP} | awk '{ print $1 }'`
            OUTPUT_JSON=$(echo ${OUTPUT_JSON} | jq -r ".gift[${i}].file_name|=\"`basename ${GIFT_ZIP}`\"")
            OUTPUT_JSON=$(echo ${OUTPUT_JSON} | jq -r ".gift[${i}].md5|=\"${HASH}\"")
            OUTPUT_JSON=$(echo ${OUTPUT_JSON} | jq -r ".gift[${i}].size|=${SIZE}")
            break
        fi
    done
done

NOW=$(TZ=UTC-9 date '+%Y%m%d%H%M%S')
OUTPUT_JSON=$(echo ${OUTPUT_JSON} | jq -r ".version|=${NOW}")

echo ${OUTPUT_JSON} > ${OUTPUT_DIR}/manifest.json

echo '*** Create Gift Zip End!! ***'
