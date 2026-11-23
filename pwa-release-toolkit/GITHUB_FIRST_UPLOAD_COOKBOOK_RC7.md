# Your first GitHub upload — beginner cookbook (v2.5 RC7)

**Goal:** Put a copy of your prepared PWA source files into a GitHub repository. This does **not** publish to the Apple or Google store.

## 1. Find your project
Open File Explorer. Find the folder containing `index.html` and its supporting `css`, `js`, `images`, and data folders. Do not confuse it with the toolkit folder. Run **Choose Project**, **Prepare Safety**, and **Check GitHub Readiness** in Excel. Read the Checks tab and logs before upload.

## 2. Make a repository
Open https://github.com/new in your browser, sign into **your account**, give your repository a name, and choose **Private** unless you intentionally want public code. Record the resulting `https://github.com/your-name/your-repo` URL in the **GitHub Upload** sheet.

## 3. Upload the files
From your empty repository choose **uploading an existing file** or **Add file → Upload files**. Select only safe source files, preserving folders. Browser upload allows **100 files per batch and up to 25 MiB per file**. For larger or more complex apps, use a Git-based upload; do not try to upload `node_modules` or secrets.

Never upload `.env`, passwords, service-account JSON keys, private certificates, `.p8`, `.p12`, `.jks`, `.key`, `.mobileprovision`, or Base64 copies of credentials. `.gitignore` is **not protection for files already uploaded or committed**. If a secret has been exposed, revoke or rotate it and follow GitHub's removal guidance.

## 4. Check it worked
Refresh your GitHub repository page. Verify `index.html` and needed directories appear. Check a few files. Record upload date, file verification, and any error in Excel. Mark **Verified** only after inspecting your own repository. No automation in RC7 uploads anything.

## 5. If the screen differs
GitHub changes its menus. Find controls by purpose, not appearance; see https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository. Screenshot illustrations in the book are simulations.

## 6. Later changes
For ongoing updates use GitHub Desktop or a reviewed Git workflow with a file-by-file safety review. GitHub Actions templates are still disabled in this release.

Official resources:
- https://github.com/new
- https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository
- https://docs.github.com/en/get-started/git-basics/ignoring-files
- https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
