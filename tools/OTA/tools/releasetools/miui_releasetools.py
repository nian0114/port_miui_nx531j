
import common
import copy

def FullOTA_Assertions(info):
  info.script.Mount("/data")

def IncrementalOTA_Assertions(info):
  info.script.Mount("/data")

def FullOTA_InstallEnd(info):
  UnpackData(info.script)
  CopyDataFiles(info.input_zip, info.output_zip, info.script)
  RemoveAbandonedPreinstall(info.script)


def IncrementalOTA_InstallEnd(info):
  UnpackData(info.script)
  RemoveAbandonedPreinstall(info.script)


def CopyDataFiles(input_zip, output_zip, script):
  """Copies files underneath data/miui in the input zip to the output zip."""

  print "[MIUI CUST] OTA: copy data files"
  for info in input_zip.infolist():
    if info.filename.startswith("DATA/miui/"):
      basefilename = info.filename[5:]
      info2 = copy.copy(info)
      info2.filename = "data/" + basefilename
      data = input_zip.read(info.filename)
      output_zip.writestr(info2, data)
  #common.ZipWriteStr(output_zip, "data/miui/reinstall_apps", "reinstall_apps")
  #script.AppendExtra("set_perm(1000, 1000, 0666, \"/data/miui/reinstall_apps\");")


def UnpackData(script):
  script.UnpackPackageDir("data", "/data")

def RemoveAbandonedPreinstall(script):
  script.AppendExtra("delete_recursive(\"/data/miui/preinstall_apps\");")
  script.AppendExtra("delete_recursive(\"/data/miui/cust/preinstall_apps\");")
