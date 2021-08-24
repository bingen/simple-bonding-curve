const fs = require('fs')
const path = require('path')

const Bancor = artifacts.require('BancorFormula')
const Simple = artifacts.require('SimpleBondingCurve')

const OUTPUT_FOLDER = 'output'
const FILE_NAME_BASE = 'bonding_curve_comparison'
const outputPathSale = path.join(OUTPUT_FOLDER, `${FILE_NAME_BASE}_sale.csv`)
const outputPathPurchase = path.join(OUTPUT_FOLDER, `${FILE_NAME_BASE}_purchase.csv`)

contract('Simple bonding curve', (accounts) => {
  let bancor, simple
  let outputStreamSale, outputStreamPurchase

  before(async() => {
    if (! fs.existsSync(OUTPUT_FOLDER)) fs.mkdirSync(OUTPUT_FOLDER)

    bancor = await Bancor.new()
    simple = await Simple.new()
    outputStreamSale = fs.createWriteStream(outputPathSale)
    outputStreamSale.write('supply(s), connectorBalance(b), 1/r, sellAmount(k), real, bancor, simple, bancor error, simple error, bancor error %, bancor abs error %, simple error %, simple abs error %, bancor gas, simple gas, gas increase %\n')
    outputStreamPurchase = fs.createWriteStream(outputPathPurchase)
    outputStreamPurchase.write('supply(s), connectorBalance(b), 1/r, buyAmount(p), real, bancor, simple, bancor error, simple error, bancor error %, bancor abs error %, simple error %, simple abs error %, bancor gas, simple gas, gas increase %\n')
  })

  //const supplies = [ 1000 ]
  const connectorBalances = [ 100 ]
  //const reverseReserveRatios = [ 1, 2, 3, 5, 10, 20, 50, 100, 1000 ]
  const reverseReserveRatios = [ 1, 2, 3, 5, 10 ]
  const divisors = [ 1000, 500, 333, 200, 100, 50, 25, 10, 5, 3, 2, 1.1, 1.05, 1.01, 1.005, 1.001, 1 ]
  //const reverseReserveRatios = [ 1000 ]
  //const divisors = [ 1.001 ]

  const REVERT = 'revert!'
  const formatRevert = (result) => result == REVERT ? `\x1b[31m${REVERT}\x1b[0m` : result

  const realPurchase = (supply, connectorBalance, reverseReserveRatio, buyAmount, log=false) => {
    const r = supply * ((1 + buyAmount / connectorBalance)**(1/reverseReserveRatio) - 1)
    if (log)
      console.log('real buy: ', supply, connectorBalance, reverseReserveRatio, buyAmount, r);
    return r
  }

  const realSale = (supply, connectorBalance, reverseReserveRatio, sellAmount, log=false) => {
    const r = connectorBalance * (1 - (1 - sellAmount / supply)**reverseReserveRatio)
    if (log)
      console.log('real sale: ', supply, connectorBalance, reverseReserveRatio, sellAmount, r);
    return r
  }

  const writeOutput = ({
    operation,
    supply,
    connectorBalance,
    reverseReserveRatio,
    amount,
    realResult,
    bancorResult,
    bancorError,
    bancorRelativeError,
    bancorGas,
    simpleResult,
    simpleError,
    simpleRelativeError,
    simpleGas,
    outputStream
  }) => {
    const computedLine = `${bancorError}, ${simpleError}, ${bancorRelativeError}, ${Math.abs(bancorRelativeError)}, ${simpleRelativeError}, ${Math.abs(simpleRelativeError)}, `
    let computedGasLine
    if (bancorResult == REVERT || simpleResult == REVERT) {
      computedGasLine = '-'
      if (operation == 'Sell') {
        console.log(`\x1b[36m${operation}\x1b[0m revert: ${formatRevert(bancorResult)}\x1b[33m vs \x1b[0m${formatRevert(simpleResult)} at: `, `\x1b[36m${supply}\x1b[0m`, connectorBalance, `\x1b[32m${reverseReserveRatio}\x1b[0m`, `\x1b[36m${amount}\x1b[0m`, `${amount * 100 / supply}%`);
      } else {
        console.log(`\x1b[46m${operation}\x1b[0m: ${formatRevert(bancorResult)}\x1b[33m vs \x1b[0m${formatRevert(simpleResult)} at: `, supply, `\x1b[46m${connectorBalance}\x1b[0m`, `\x1b[32m${reverseReserveRatio}\x1b[0m`, `\x1b[46m${amount}\x1b[0m`, `${amount * 100 / connectorBalance}%`);
      }
    } else {
      computedGasLine = `${(simpleGas - bancorGas) / bancorGas}`
    }
    const line = `${supply}, ${connectorBalance}, ${reverseReserveRatio}, ${amount}, ${realResult}, ` +
          `${bancorResult}, ${simpleResult}, ` +
          computedLine +
          `${bancorGas}, ${simpleGas}, ` + computedGasLine
    outputStream.write(line + '\n')
  }

  const compareSale = async(supply, connectorBalance, reverseReserveRatio, sellAmount) => {
    const realResult = realSale(supply, connectorBalance, reverseReserveRatio, sellAmount)

    let bancorResult
    let bancorError
    let bancorRelativeError
    let bancorGas
    try {
      bancorResult = (await bancor.calculateSaleReturn(supply, connectorBalance, 1e6 / reverseReserveRatio, sellAmount)).toNumber()
      bancorError = bancorResult - realResult
      bancorRelativeError = (bancorResult - realResult) / realResult
      bancorGas = await bancor.calculateSaleReturn.estimateGas(supply, connectorBalance, 1e6 / reverseReserveRatio, sellAmount)
    } catch (e) {
      bancorResult = REVERT
      bancorError = '-'
      bancorRelativeError = '-'
      bancorGas = '-'
    }

    let simpleResult
    let simpleError
    let simpleRelativeError
    let simpleGas
    try {
      simpleResult = (await simple.calculateSaleReturn2(supply, connectorBalance, reverseReserveRatio - 1, sellAmount)).toNumber()
      simpleError = simpleResult - realResult
      simpleRelativeError = (simpleResult - realResult) / realResult
      simpleGas = await simple.calculateSaleReturn2.estimateGas(supply, connectorBalance, reverseReserveRatio - 1, sellAmount)
    } catch (e) {
      simpleResult = REVERT
      simpleError = '-'
      simpleRelativeError = '-'
      simpleGas = '-'
    }

    writeOutput({
      operation: 'Sell',
      supply,
      connectorBalance,
      reverseReserveRatio,
      amount: sellAmount,
      realResult,
      bancorResult,
      bancorError,
      bancorRelativeError,
      bancorGas,
      simpleResult,
      simpleError,
      simpleRelativeError,
      simpleGas,
      outputStream: outputStreamSale,
    })
    //console.log('sale comparison', line)
  }

  const compareBuy = async(supply, connectorBalance, reverseReserveRatio, buyAmount) => {
    const realResult = realPurchase(supply, connectorBalance, reverseReserveRatio, buyAmount)

    let bancorResult
    let bancorError
    let bancorRelativeError
    let bancorGas
    try {
      bancorResult = (await bancor.calculatePurchaseReturn(supply, connectorBalance, 1e6 / reverseReserveRatio, buyAmount)).toNumber()
      bancorError = bancorResult - realResult
      bancorRelativeError = (bancorResult - realResult) / realResult
      bancorGas = await bancor.calculatePurchaseReturn.estimateGas(supply, connectorBalance, 1e6 / reverseReserveRatio, buyAmount)
    } catch (e) {
      bancorResult = REVERT
      bancorError = '-'
      bancorRelativeError = '-'
      bancorGas = '-'
    }

    let simpleResult
    let simpleError
    let simpleRelativeError
    let simpleGas
    try {
      simpleResult = (await simple.calculatePurchaseReturn2(supply, connectorBalance, reverseReserveRatio - 1, buyAmount)).toNumber()
      simpleError = simpleResult - realResult
      simpleRelativeError = (simpleResult - realResult) / realResult
      simpleGas = await simple.calculatePurchaseReturn2.estimateGas(supply, connectorBalance, reverseReserveRatio - 1, buyAmount)
    } catch (e) {
      console.log(e)
      simpleResult = REVERT
      simpleError = '-'
      simpleRelativeError = '-'
      simpleGas = '-'
    }

    writeOutput({
      operation: 'Buy',
      supply,
      connectorBalance,
      reverseReserveRatio,
      amount: buyAmount,
      realResult,
      bancorResult,
      bancorError,
      bancorRelativeError,
      bancorGas,
      simpleResult,
      simpleError,
      simpleRelativeError,
      simpleGas,
      outputStream: outputStreamPurchase,
    })
    //console.log('purchase comparison', line)
  }

  const bancorSale = async(supply, connectorBalance, reverseReserveRatio, sellAmount) => {
    let bancorResult
    try {
      bancorResult = (await bancor.calculateSaleReturn(supply, connectorBalance, 1e6 / reverseReserveRatio, sellAmount)).toNumber()
    } catch (e) {
      bancorResult = REVERT
    }
    console.log('bancor sale:', supply, connectorBalance, reverseReserveRatio, sellAmount, bancorResult);
  }

  const simpleSale = async(supply, connectorBalance, reverseReserveRatio, sellAmount) => {
    const simpleResult = await simple.calculateSaleReturn2(supply, connectorBalance, reverseReserveRatio - 1, sellAmount)
    console.log('simple sale: ', supply, connectorBalance, reverseReserveRatio, sellAmount, simpleResult.toNumber());
  }

  const bancorBuy = async(supply, connectorBalance, reverseReserveRatio, buyAmount) => {
    const bancorResult = await bancor.calculatePurchaseReturn(supply, connectorBalance, 1e6 / reverseReserveRatio, buyAmount)
    console.log('bancor buy:', supply, connectorBalance, reverseReserveRatio, buyAmount, bancorResult.toNumber());
  }

  const simpleBuy = async(supply, connectorBalance, reverseReserveRatio, buyAmount) => {
    //console.log(await simple.rootFixed2("1200000000000000000", 2, 3, "1500000000000000000"));
    const simpleResult = await simple.calculatePurchaseReturn2(supply, connectorBalance, reverseReserveRatio - 1, buyAmount)
    console.log('simple buy: ', supply, connectorBalance, reverseReserveRatio, buyAmount, simpleResult.toNumber());
  }

  const nestedMaps = async(f) => {
    const sellAmounts = []
    const buyAmounts = []
    const generateInputAmounts = (total) =>
          divisors.map(d => Math.floor(total / d)).filter(x => x > 0)
    const generateMultiplierInputAmounts = (total) => divisors.map(d => total * d)
    await Promise.all(connectorBalances.map(
      connectorBalance => reverseReserveRatios.map(
        reverseReserveRatio => {
          const supply = connectorBalance * reverseReserveRatio
          //console.log('sell', supply, divisors, generateInputAmounts(supply));
          //console.log('buy', connectorBalance, divisors, generateInputAmounts(connectorBalance));
          return f(
            supply,
            connectorBalance,
            reverseReserveRatio,
            generateInputAmounts(supply), // sellAmounts
            generateInputAmounts(connectorBalance).
              concat(generateMultiplierInputAmounts(connectorBalance)) // buyAmounts
          )
        }
      ).reduce((acc, val) => acc.concat(val), [])
    ).reduce((acc, val) => acc.concat(val), []))
  }

  const versions = [
    {
      name: "weis",
      preProcess: x => x
    },
    {
      name: "gweis",
      preProcess: x => x * 1e9
    },
    {
      name: "units",
      preProcess: x => web3.toWei(x)
    }
  ]
  for (const version of versions) {
    context.only(`Comparison of ${version.name}`, () => {
      it(`compares using ${version.name}`, async () => {
        const f = (supply, connectorBalance, reverseReserveRatio, sellAmounts, buyAmounts) => {
          //console.log(version.preProcess(supply), version.preProcess(connectorBalance), reverseReserveRatio);
          const sPromises = sellAmounts.map(
            sellAmount => compareSale(version.preProcess(supply), version.preProcess(connectorBalance), reverseReserveRatio, version.preProcess(sellAmount))
          )
          const bPromises = buyAmounts.map(
            buyAmount => compareBuy(version.preProcess(supply), version.preProcess(connectorBalance), reverseReserveRatio, version.preProcess(buyAmount))
          )
          return sPromises.concat(bPromises)
        }

        await nestedMaps(f)
      })
    })

    context(`Sales of ${version.name}`, () => {
      it('Bancor sales', async () => {
        const f = (supply, connectorBalance, reverseReserveRatio) => {
          return sellAmounts.map(
            sellAmount => bancorSale(version.preProcess(supply), version.preProcess(connectorBalance), reverseReserveRatio, version.preProcess(sellAmount))
          )
        }

        await nestedMaps(f)
      })

      it('Simple sales', async () => {
        const f = (supply, connectorBalance, reverseReserveRatio) => {
          return sellAmounts.map(
            sellAmount => simpleSale(version.preProcess(supply), version.preProcess(connectorBalance), reverseReserveRatio, version.preProcess(sellAmount))
          )
        }

        await nestedMaps(f)
      })

      it('Real sales', async () => {
        const f = (supply, connectorBalance, reverseReserveRatio) => {
          return sellAmounts.map(
            sellAmount => realSale(version.preProcess(supply), version.preProcess(connectorBalance), reverseReserveRatio, version.preProcess(sellAmount), true)
          )
        }

        await nestedMaps(f)
      })
    })

    context(`Purchases of ${version.name}`, () => {
      it('Bancor buys', async () => {
        const f = (supply, connectorBalance, reverseReserveRatio) => {
          return buyAmounts.map(
            buyAmount => bancorBuy(version.preProcess(supply), version.preProcess(connectorBalance), reverseReserveRatio, version.preProcess(buyAmount))
          )
        }

        await nestedMaps(f)
      })

      it('Simple buys', async () => {
        const f = (supply, connectorBalance, reverseReserveRatio) => {
          return buyAmounts.map(
            buyAmount => simpleBuy(version.preProcess(supply), version.preProcess(connectorBalance), reverseReserveRatio, version.preProcess(buyAmount))
          )
        }

        await nestedMaps(f)
      })

      it('Real buys', async () => {
        const f = (supply, connectorBalance, reverseReserveRatio) => {
          return buyAmounts.map(
            buyAmount => realPurchase(version.preProcess(supply), version.preProcess(connectorBalance), reverseReserveRatio, version.preProcess(buyAmount), true)
          )
        }

        await nestedMaps(f)
      })
    })
  }

  context.only('Compare buy edge cases', () => {
    it('Edge case without revert', async () => {
      const connectorBalance = '1'
      const reverseReserveRatio = 2
      const supply = connectorBalance * reverseReserveRatio
      const buyAmount = 1e27

      await compareBuy(supply, connectorBalance, reverseReserveRatio, buyAmount)
    })

    it('Edge case with revert', async () => {
      const connectorBalance = '1'
      const reverseReserveRatio = 2
      const supply = connectorBalance * reverseReserveRatio
      const buyAmount = 7e38

      await compareBuy(supply, connectorBalance, reverseReserveRatio, buyAmount)
    })
  })
})
