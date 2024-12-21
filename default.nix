{ lib
, buildNimPackage
}:
buildNimPackage (finalAttrs: {
  pname = "webfisher";
  version = "0.1.0";

  src = ./.;

  strictDeps = true;

  lockFile = ./lock.json;

  buildInputs = [ ];

  meta = with lib; {
    description = "A Nim based fishing script for Webfishing";
    homepage = "https://github.com/passiveLemon/webfisheer";
    changelog = "https://github.com/passiveLemon/webfisher/releases/tag/${finalAttrs.version}";
    license = licenses.gpl3;
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "webfisher";
  };
})
