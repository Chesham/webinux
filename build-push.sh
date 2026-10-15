#!/bin/sh
# 建置並推送 webinux 映像（這個 repo 沒有 GitLab CI，照 ib-gateway 的 CI 規則手動跑）：
#   每個 commit 只建一次、只推不可覆蓋的 `main-<8 碼 sha>`；別名 `latest` 用 imagetools 指過去
#   （只傳 manifest，摘要不變、不重傳）。registry 的清理規則只清 `^main-[0-9a-f]{8}$`、別名永遠保留。
# 用法：先 `docker login <registry>`（要有寫入 registry 的權限），再在 repo 根目錄執行
#   ./build-push.sh
# 只建已 commit 的內容（git archive HEAD），工作目錄有未 commit 的改動就拒絕執行。
set -eu

REPO=${REPO:-<registry>/chesham/ib-gateway/webinux}
ALIAS=${ALIAS:-latest}

if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
    echo "working tree has uncommitted changes; commit first" >&2
    exit 1
fi
SHA=$(git rev-parse --short=8 HEAD)
IMAGE="$REPO:main-$SHA"

# 已經存在就不重建（永不覆蓋）；查詢失敗但不是「找不到」就停下，不把「查不到」當成「不存在」
if out=$(docker buildx imagetools inspect "$IMAGE" 2>&1); then
    echo "$IMAGE already in the registry; not rebuilding (never overwritten)"
elif echo "$out" | grep -q ': not found$'; then
    git archive HEAD | docker build -t "$IMAGE" -
    docker push "$IMAGE"
else
    echo "$out" >&2
    echo "cannot tell whether $IMAGE exists; stopping" >&2
    exit 1
fi

# `--prefer-index=false` 不能省：省掉的話 buildx 會多包一層 index，別名的摘要就和 `main-<sha>` 不同
docker buildx imagetools create --prefer-index=false -t "$REPO:$ALIAS" "$IMAGE"
docker buildx imagetools inspect "$IMAGE" | grep -m1 '^Digest:'
