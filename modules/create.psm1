function New-Manifest {
    param(
        [PackDirectory] $packDir = "",
        [Version] $version = 1
    )

    $packDir = Read-Host
}

Export-ModuleMember -Function New-Manifest